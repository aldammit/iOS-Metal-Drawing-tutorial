//
//  CollorPickerBottomSheetController.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit
import Combine

class CollorPickerBottomSheetController: UIViewController {
    
    enum Section: Int {
        case main
    }
    
    enum Item: Hashable {
        case add
        case paletteItem(item: PaletteItem)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .add:
                hasher.combine("add")
            case .paletteItem(let item):
                hasher.combine(item.hashValue)
            }
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            switch lhs {
            case .add:
                if case .add = rhs {
                    return true
                } else {
                    return false
                }
            case .paletteItem(let lhsItem):
                if case .paletteItem(let rhsItem) = rhs {
                    return lhsItem == rhsItem
                } else {
                    return false
                }
            }
        }
    }
    
    struct PaletteItem: Hashable {
        let color: Color
        let id: String
        init(color: Color, id: String) {
            self.color = color
            self.id = id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(color.hex)
        }

        static func == (lhs: PaletteItem, rhs: PaletteItem) -> Bool {
            return lhs.id == rhs.id && lhs.color.hex == rhs.color.hex
        }
    }
    
    let viewModel: EditorBottomViewModel
    var presentationCotntroller: ColorPickerPresentationController!
    
    private lazy var contentView: ColorPickerBottomSheetView = .init(viewModel: viewModel, frame: .zero)
    private var bindings = Set<AnyCancellable>()
    
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private var selectedPaletteItem: PaletteItem?
    
    init(viewModel: EditorBottomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    class func buildAndPresent(viewController: UIViewController, viewModel: EditorBottomViewModel) {
        let picker = CollorPickerBottomSheetController(viewModel: viewModel)
        picker.presentationCotntroller = ColorPickerPresentationController(presentedViewController: picker, presenting: viewController, scrollView: picker.contentView.scrollView)
        picker.initialSetup()
        viewController.present(picker, animated: true)
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    deinit {
        print("EditorColorPickerPopup deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = UICollectionViewDiffableDataSource(collectionView: contentView.palleteCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorPaletteCollectionViewCell.self), for: indexPath) as? ColorPaletteCollectionViewCell
            switch item {
            case .paletteItem(let item):
                if item == self.selectedPaletteItem {
                    cell?.isSelected = true
                } else {
                    cell?.isSelected = false
                }
            case .add:
                cell?.isSelected = false
            }
            cell?.setup(with: item)
            return cell ?? UICollectionViewCell()
        })
        contentView.palleteCollectionView.delegate = self
        reloadPaletteDataSource()
    }
    
    private func initialSetup() {
        modalPresentationStyle = .custom
        transitioningDelegate = presentationCotntroller
        setupBindings()
    }

    private func setupBindings() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .colorPicker(let color, _, _):
                    self.contentView.sliderInputView.opacitySlider.updateSelectedColor(color: color)
                    self.contentView.sliderInputView.opacityTextField.text = (color.alpha * 100).int.string + "%"
                    self.contentView.selectedColorView.backgroundColor = color.uiColor
                default: break
                }
            }.store(in: &bindings)
                
        
        contentView.closeButton.publisher(for: .touchUpInside)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.viewModel.hideColorPicker()
                self?.dismiss(animated: true)
            }.store(in: &bindings)
        
        contentView.sliderInputView.opacitySlider.publisher(for: .valueChanged)
            .compactMap { $0 as? ColorPickerSlider }
            .receive(on: RunLoop.main)
            .sink { [weak self] slider in
                guard let self else { return }
                self.viewModel.updateColorOpacity(opacity: (slider.value * 100).int)
            }.store(in: &bindings)
        
        contentView.segmentedControl.publisher(for: .valueChanged)
            .compactMap { $0 as? UISegmentedControl }
            .receive(on: RunLoop.main)
            .sink { [weak self] segmentedControl in
                guard let self else { return }
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    self.contentView.showGridColorPicker()
                case 1:
                    self.contentView.showSpectrumColorPicker()
                default: break
                }
            }.store(in: &bindings)

    }
    
    private func reloadPaletteDataSource() {
        var snapshot = dataSource?.snapshot()
        if !(snapshot?.sectionIdentifiers.contains(.main) ?? false) {
            snapshot?.appendSections([.main])
        }
        let colors = Color.defaultPalette() + Color.fetchSavedColors()
        var paletteItems: [Item] = []
        colors.enumerated().forEach { (index, color) in
            paletteItems.append(.paletteItem(item: .init(color: color, id: index.string)))
        }
        paletteItems.append(.add)
        snapshot?.appendItems(paletteItems)
        dataSource?.apply(snapshot!, animatingDifferences: true)
    }
}

extension CollorPickerBottomSheetController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorPaletteCollectionViewCell, let item = cell.item {
            switch item {
            case .add:
                viewModel.selectedColor.save()
            case .paletteItem(let paletteItem):
                viewModel.updateValuesInColorPicker(color: paletteItem.color, source: .palette)
                selectedPaletteItem = paletteItem
            }
            reloadPaletteDataSource()
        }
    }
}
