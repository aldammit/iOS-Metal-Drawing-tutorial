//
//  ColorPickerBottomSheetView.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import Combine
import UIKit

class ColorPickerBottomSheetView: UIView {
    
    private var blurView: UIVisualEffectView?
    private let blurIntencity = CGFloat(0.2)
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var scrollView: UIScrollView = UIScrollView()
    
    private(set) lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    private(set) lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl()
        segmented.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.3)
        segmented.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        segmented.insertSegment(withTitle: "Grid", at: 0, animated: false)
        segmented.insertSegment(withTitle: "Spectrum", at: 1, animated: false)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmented.selectedSegmentIndex = 0
        return segmented
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Colors"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
        
    private lazy var opacityTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "OPACITY"
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(hex: "EBEBF5")?.withAlphaComponent(0.6)
        return label
    }()
    
    private(set) lazy var sliderInputView: ColorPickerSliderInputView = {
        let inputView = ColorPickerSliderInputView(scrollView: self.scrollView) { [weak self] opacity in
            self?.viewModel.updateColorOpacity(opacity: opacity)
        }
        return inputView
    }()
    
    private lazy var divider: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "48484A")
        return view
    }()
    
    private(set) lazy var selectedColorView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .blue
        return view
    }()
    
    private(set) lazy var palleteCollectionView: UICollectionView = {
        let paletteItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(30), heightDimension: .absolute(30)))
        
        let maxElementsCount = Int((UIScreen.main.bounds.width - 150 + 22)/52)
        let subitems = Array(repeating: paletteItem, count: maxElementsCount)

        let topLineGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitems: subitems)
        topLineGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(22)
        topLineGroup.contentInsets = .init(top: .zero, leading: .zero, bottom: 11, trailing: .zero)
        
        let botLineGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitems: subitems)
        botLineGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(22)
        botLineGroup.contentInsets = .init(top: 11, leading: .zero, bottom: .zero, trailing: .zero)
        
        let verticalAligmentGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [topLineGroup, botLineGroup])
        
        let section = NSCollectionLayoutSection(group: verticalAligmentGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ColorPaletteCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: ColorPaletteCollectionViewCell.self))
        collection.backgroundColor = .clear
        collection.bounces = false
        return collection
    }()
    
    private var bindings = Set<AnyCancellable>()
    private let viewModel: EditorBottomViewModel
    private let colorPickerViewRootView = UIView(frame: .zero)

    init(viewModel: EditorBottomViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        let view = UIVisualEffectView(effect: nil)
        self.blurView = view
        self.blurView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(self.blurView!)
        contentView.addSubview(closeButton)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(titleLabel)
        contentView.addSubview(colorPickerViewRootView)
        contentView.addSubview(selectedColorView)
        contentView.addSubview(sliderInputView)
        contentView.addSubview(opacityTitle)
        contentView.addSubview(divider)
        contentView.addSubview(palleteCollectionView)
        
        setupLayout()
        showGridColorPicker()
    }
    
    private func setupLayout() {
        closeButton.pinToSuperviewEdgesWithInsets(top: 14, right: 16)
        segmentedControl.pinToSuperviewEdgesWithInsets(left: 16, right: 16)
        colorPickerViewRootView.pinToSuperviewEdgesWithInsets(left: 16, right: 16)
        opacityTitle.pinToSuperviewEdgesWithInsets(left: 16, right: 16)
        titleLabel.pinToSuperviewEdgesWithInsets(left: 50, right: 50)
        sliderInputView.pinToSuperviewEdgesWithInsets(left: .zero, right: .zero)
        divider.pinToSuperviewEdgesWithInsets(left: 16, right: 16)
        selectedColorView.pinToSuperviewEdgesWithInsets(left: 16)
        palleteCollectionView.pinToSuperviewEdgesWithInsets(right: 16)
        scrollView.pinToSuperviewEdges()
        contentView.pinToSuperviewEdges()
        
        closeButton.alignSize(to: CGSize(size: 30))
        selectedColorView.alignSize(to: CGSize(width: 82, height: 82))
                        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            segmentedControl.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 14),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),
            colorPickerViewRootView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            opacityTitle.topAnchor.constraint(equalTo: colorPickerViewRootView.bottomAnchor, constant: 16),
            opacityTitle.heightAnchor.constraint(equalToConstant: 18),
            sliderInputView.topAnchor.constraint(equalTo: opacityTitle.bottomAnchor),
            sliderInputView.heightAnchor.constraint(equalToConstant: 64),
            divider.topAnchor.constraint(equalTo: sliderInputView.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            selectedColorView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 22),
            selectedColorView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            palleteCollectionView.leftAnchor.constraint(equalTo: selectedColorView.rightAnchor, constant: 36),
            palleteCollectionView.topAnchor.constraint(equalTo: selectedColorView.topAnchor),
            palleteCollectionView.bottomAnchor.constraint(equalTo: selectedColorView.bottomAnchor)
        ])

        if let blurView {
            NSLayoutConstraint.activate([
                blurView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                blurView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                blurView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1 / blurIntencity),
                blurView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1 / blurIntencity)
            ])
                    
            blurView.transform = CGAffineTransform(scaleX: blurIntencity, y: blurIntencity)
            blurView.effect = UIBlurEffect(style: .dark)
            blurView.subviews.forEach {
                $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                $0.layer.cornerRadius = 10 / blurIntencity
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let parentHitTest = super.hitTest(point, with: event)
        return parentHitTest
    }
    
    func showSpectrumColorPicker() {
        colorPickerViewRootView.subviews.forEach({ $0.removeFromSuperview() })
        let spectrumView = ColorPickerSpectrumView(viewModel: viewModel, frame: colorPickerViewRootView.bounds)
        colorPickerViewRootView.addSubview(spectrumView)
        spectrumView.pinToSuperviewEdges()
    }
    
    func showGridColorPicker() {
        colorPickerViewRootView.subviews.forEach({ $0.removeFromSuperview() })
        let gridView = ColorPickerGridView(viewModel: viewModel, frame: colorPickerViewRootView.bounds)
        colorPickerViewRootView.addSubview(gridView)
        gridView.pinToSuperviewEdges()
    }
}
