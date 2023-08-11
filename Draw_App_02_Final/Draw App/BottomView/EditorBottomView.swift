//
//  EditorBottomView.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit
import Combine
 
class EditorBottomView: UIView {
    
    let segmentedControl = EditorBottomSegementedControl()

    lazy var colorPickerButton: UIButton = {
        let button = UIButton(type: .custom).forAutoLayout()
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom).forAutoLayout()
        button.setImage(UIImage.generateCloseButtonForTools(), for: .normal)
        return button
    }()
    
    lazy var toolsGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        gradientLayer.locations = [0.8, 0.9, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()
    
    lazy var blurBackgroundMaskGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()
    
    lazy var blurBackgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.2, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()
    
    lazy var blackBackground: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let black = UIVisualEffectView(effect: effect)
        black.contentView.layer.addSublayer(blurBackgroundMaskGradientLayer)
        return black
    }()
    
    lazy var toolsStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.axis = .horizontal
        let images = viewModel.brushes.map({ $0.icon() })
        viewModel.brushes.forEach { brush in
            let img = brush.icon()
            let imageView = UIImageView(image: img)
            imageView.contentMode = .scaleAspectFit
            if brush.isAvailable {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toolTapGestureHandled))
                imageView.addGestureRecognizer(tapGesture)
                imageView.isUserInteractionEnabled = true
                imageView.alpha = 1.0
            } else {
                imageView.alpha = 0.5
            }
            stack.addArrangedSubview(imageView)
        }
        stack.layer.addSublayer(toolsGradientLayer)
        return stack
    }()
    
    let viewModel: EditorBottomViewModel
    private var sliderBackgroundLayer: CAShapeLayer?
    private var sliderCircleLayer: CAShapeLayer?
    
    private var bindings = Set<AnyCancellable>()
    
    init(viewModel: EditorBottomViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        toolsGradientLayer.frame = CGRect(x: 0, y: -25, width: toolsStackView.bounds.width, height: toolsStackView.bounds.height + 25)
        toolsStackView.layer.mask = toolsGradientLayer
        blurBackgroundMaskGradientLayer.frame = blackBackground.bounds
        blackBackground.layer.mask = blurBackgroundMaskGradientLayer
        blurBackgroundGradientLayer.frame = blackBackground.frame
    }
    
    func selectTool() {
        self.toolsStackView.arrangedSubviews.enumerated().forEach { (index, view) in
            if index == self.viewModel.selectedBrushIndex {
                if view.transform == .identity {
                    view.transform = CGAffineTransform(scaleX: 1.30, y: 1.30).concatenating(CGAffineTransform(translationX: 0, y: -10))
                }
            } else {
                view.transform = .identity
            }
        }
    }
    
    func performInitialAnimation(duration: TimeInterval) {
        let animationArray: [(view: UIView, translationY: CGFloat)] = [
            (colorPickerButton, 80)
        ] + toolsStackView.arrangedSubviews.map({ ($0, 105) })
       
        for (index, animation) in animationArray.enumerated() {
            var delay = (index.double - 1) * 0.08
            var duration = duration
            if index == 0 || index == 1 {
                delay = 0.02
                duration = duration * 1.5
            }
            animation.view.alpha = .zero
            
            animation.view.transform = CGAffineTransform(translationX: .zero, y: animation.translationY)
       
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut) {
                if (index - 2) == self.viewModel.selectedBrushIndex {
                    animation.view.transform = .identity.scaledBy(x: 1.30, y: 1.30).translatedBy(x: .zero, y: -10)
                } else {
                    animation.view.transform = .identity
                }
            }
            
            UIView.animate(withDuration: duration, delay: delay + 0.02) {
                animation.view.alpha = 1.0
            }
            
            CATransaction.commit()
        }
    }
    
    private func commonInit() {
//        clipsToBounds = true
        addSubview(blackBackground)
        layer.addSublayer(blurBackgroundGradientLayer)
        addSubview(toolsStackView)
        addSubview(segmentedControl)
        addSubview(colorPickerButton)
        addSubview(closeButton)
        closeButton.isHidden = true
        segmentedControl.insertSegment(withTitle: "Draw", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Clear", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        setupBindings()
        setupLayout()
    }
        
    private func setupBindings() {
        colorPickerButton.publisher(for: .touchUpInside).receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.selectColorPicker()
        }.store(in: &bindings)
        
        closeButton.publisher(for: .touchUpInside).receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.cancelButtonPressed()
        }.store(in: &bindings)
        
        viewModel.$state.receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .draw(let brush, _):
                    print("hide all other view and update selected colors")
                    self.colorPickerButton.setImage(UIImage.generateColorPickerIcon(selectedColor: brush.color.uiColor), for: .normal)
                    if let toolImage = self.toolsStackView.arrangedSubviews[self.viewModel.selectedBrushIndex] as? UIImageView {
                        toolImage.image = self.viewModel.selectedBrush.icon()
                    }
                    self.sliderCircleLayer?.fillColor = self.viewModel.selectedColor.uiColor.cgColor
                    
                case .brushConfiguration(let brush, let presentationState):
                    print("show brush configuration")
                    switch presentationState {
                    case .show:
                        self.openSizeEditor(for: self.viewModel.selectedBrushIndex)
                        self.closeButton.isHidden = false
                        self.colorPickerButton.isHidden = true
                    case .hide:
                        self.closeButton.isHidden = true
                        self.colorPickerButton.isHidden = false
                        self.hideSlider()
                    case .updated:
                        (self.toolsStackView.arrangedSubviews[self.viewModel.selectedBrushIndex] as? UIImageView)?.image = brush.icon()
                    }
                case .clear(_):
                    self.segmentedControl.selectedSegmentIndex = 0
                    self.viewModel.selectDrawTab()
                default:
                    break
                }
            }.store(in: &bindings)
        
        segmentedControl
            .publisher(for: .valueChanged)
            .receive(on: RunLoop.main)
            .sink { control in
                if let segmentedControl = control as? EditorBottomSegementedControl {
                    switch segmentedControl.selectedSegmentIndex {
                    case 0: self.viewModel.selectDrawTab()
                    case 1: self.viewModel.state = .clear(presentationState: .show)
                    default: break
                    }
                }
            }.store(in: &bindings)
        
    }
        
    private func setupLayout() {
        clipsToBounds = false
        toolsStackView.pinToSuperviewEdgesWithInsets(left: 75, right: 75)
        
        let safeAreaInsets = UIApplication.shared.window?.safeAreaInsets ?? .zero
        blackBackground.pinToSuperviewEdgesWithInsets(left: -safeAreaInsets.left, right: -safeAreaInsets.right, bottom: -safeAreaInsets.bottom, respectingSafeArea: false)
        
        
        colorPickerButton.alignSize(to: CGSize(size: 33))
        closeButton.alignSize(to: CGSize(size: 33))
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandled))
        addGestureRecognizer(panGesture)
        
        NSLayoutConstraint.activate([
            blackBackground.topAnchor.constraint(equalTo: toolsStackView.topAnchor, constant: -80),
            colorPickerButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            colorPickerButton.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero),
            closeButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero),
            segmentedControl.leftAnchor.constraint(equalTo: leftAnchor, constant: 16 + 33 + 8),
            segmentedControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -16 - 33 - 8),
            segmentedControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0),
            segmentedControl.heightAnchor.constraint(equalToConstant: 33),
            toolsStackView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: 0),
            toolsStackView.heightAnchor.constraint(equalToConstant: 82)
        ])
     }
        
    private func openSizeEditor(for selectedIndex: Int) {
        makeSliderAnimation(selectedIndex: selectedIndex, isReversed: false) { [weak self] in
            guard let self else { return }
            self.segmentedControl.isUserInteractionEnabled = false
        }
    }
    
    private func hideSlider() {
        makeSliderAnimation(selectedIndex: viewModel.selectedBrushIndex, isReversed: true) { [weak self] in
            guard let self else { return }
            self.segmentedControl.isUserInteractionEnabled = true
            self.segmentedControl.layer.removeAllAnimations()
        }
    }
    
    private func makeSliderAnimation(selectedIndex: Int, isReversed: Bool, completionHandler: (() -> Void)?) {
        let animationArray: [(view: UIView, translationY: CGFloat)] = toolsStackView.arrangedSubviews.map({ ($0, 82) })
       
        let duration = 0.5
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completionHandler?()
        }
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
                
        let segmentedBounds = self.segmentedControl.bounds
        let halfHeight = segmentedBounds.height / 2
        let width = segmentedBounds.width
        let height = segmentedBounds.height

        let segmentedTempBezierPath = UIBezierPath()
        segmentedTempBezierPath.move(to: CGPoint(x: halfHeight, y: .zero))
        segmentedTempBezierPath.addLine(to: CGPoint(x: width - halfHeight, y: .zero))
        segmentedTempBezierPath.addCurve(to: CGPoint(x: width, y: halfHeight), controlPoint1: CGPoint(x: width - halfHeight / 2, y: .zero), controlPoint2: CGPoint(x: width, y: height / 5))
        segmentedTempBezierPath.addCurve(to: CGPoint(x: width - halfHeight, y: height), controlPoint1: CGPoint(x: width, y: height - height / 5), controlPoint2: CGPoint(x: width - halfHeight / 2, y: height))
        segmentedTempBezierPath.addLine(to: CGPoint(x: halfHeight, y: height))
        segmentedTempBezierPath.addCurve(to: CGPoint(x: .zero, y: halfHeight), controlPoint1: CGPoint(x: halfHeight / 2, y: height), controlPoint2: CGPoint(x: .zero, y: height - height / 5))
        segmentedTempBezierPath.addCurve(to: CGPoint(x: halfHeight, y: .zero), controlPoint1: CGPoint(x: .zero, y: height / 5), controlPoint2: CGPoint(x: halfHeight / 2, y: .zero))
        segmentedTempBezierPath.close()

        if sliderBackgroundLayer == nil {
            sliderBackgroundLayer = CAShapeLayer()
            sliderBackgroundLayer?.frame = self.segmentedControl.frame
            self.layer.addSublayer(sliderBackgroundLayer!)
        }
                
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.fillMode = .forwards
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = false
        
        if isReversed {
            let reversedOpacityAnimation = opacityAnimation.copy() as! CABasicAnimation
            reversedOpacityAnimation.fromValue = 0.0
            reversedOpacityAnimation.toValue = 1.0
            reversedOpacityAnimation.fillMode = .backwards
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.segmentedControl.layer.add(reversedOpacityAnimation, forKey: "segmentedControlOpacityAnimation")
        } else {
            self.segmentedControl.layer.add(opacityAnimation, forKey: "segmentedControlOpacityAnimation")
            sliderCircleLayer?.opacity = 1.0
            sliderBackgroundLayer?.opacity = 1.0
        }
        
        let sliderPath = UIBezierPath()
        sliderPath.move(to: CGPoint(x: .zero, y: halfHeight))
        sliderPath.addCurve(to: CGPoint(x: halfHeight / 3, y: halfHeight / 4 * 3), controlPoint1: CGPoint(x: .zero, y: halfHeight / 4 * 3), controlPoint2: CGPoint(x: .zero, y: halfHeight / 4 * 3))
        sliderPath.addLine(to: CGPoint(x: width - halfHeight, y: .zero))
        sliderPath.addCurve(to: CGPoint(x: width, y: halfHeight), controlPoint1: CGPoint(x: width - halfHeight / 2, y: .zero), controlPoint2: CGPoint(x: width, y: height / 5))
        sliderPath.addCurve(to: CGPoint(x: width - halfHeight, y: height), controlPoint1: CGPoint(x: width, y: height - halfHeight / 2), controlPoint2: CGPoint(x: width - halfHeight / 2, y: height))
        sliderPath.addLine(to: CGPoint(x: halfHeight / 3, y: halfHeight + halfHeight / 4))
        sliderPath.addCurve(to: CGPoint(x: .zero, y: halfHeight), controlPoint1: CGPoint(x: .zero, y: halfHeight + halfHeight / 4), controlPoint2: CGPoint(x: .zero, y: halfHeight))
        sliderPath.close()

        let segmentedAnimation = CABasicAnimation(keyPath: "path")
        if isReversed {
            segmentedAnimation.fromValue = sliderPath.cgPath
            segmentedAnimation.toValue = segmentedTempBezierPath.cgPath
        } else {
            segmentedAnimation.fromValue = segmentedTempBezierPath.cgPath
            segmentedAnimation.toValue = sliderPath.cgPath
        }
        segmentedAnimation.beginTime = .zero
        segmentedAnimation.duration = duration
        segmentedAnimation.fillMode = .forwards
        segmentedAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        segmentedAnimation.isRemovedOnCompletion = false
        
        if let sliderBackgroundLayer {
            sliderBackgroundLayer.path = isReversed ? sliderPath.cgPath : segmentedTempBezierPath.cgPath
            sliderBackgroundLayer.fillColor = self.segmentedControl.selectedSegmentTintColor?.cgColor
            sliderBackgroundLayer.removeAllAnimations()
            sliderBackgroundLayer.add(segmentedAnimation, forKey: "sliderPathAnimation")
            if isReversed {
                sliderBackgroundLayer.add(opacityAnimation, forKey: "sliderOpacityAnimation")
            }
        }

        
        let halfSegmentedTempBezierPath = UIBezierPath(roundedRect: CGRect(x: .zero, y: .zero, width: width / 2, height: height),
                                                       cornerRadius: halfHeight)
        if sliderCircleLayer == nil {
            sliderCircleLayer = CAShapeLayer()
            sliderCircleLayer?.frame = CGRect(x: self.segmentedControl.frame.origin.x, y: self.segmentedControl.frame.origin.y, width: width / 2, height: height)
            self.layer.addSublayer(sliderCircleLayer!)
        }

        let circlePath = UIBezierPath(roundedRect: CGRect(x: (width - height) / 2, y: .zero, width: height, height: height), cornerRadius: halfHeight)
        let circleAnimation = CABasicAnimation(keyPath: "path")
        if isReversed {
            circleAnimation.fromValue = circlePath.cgPath
            circleAnimation.toValue = halfSegmentedTempBezierPath.cgPath
        } else {
            circleAnimation.fromValue = halfSegmentedTempBezierPath.cgPath
            circleAnimation.toValue = circlePath.cgPath
        }
        circleAnimation.beginTime = .zero
        circleAnimation.duration = duration
        circleAnimation.fillMode = .forwards
        circleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        circleAnimation.isRemovedOnCompletion = false
        
        if let sliderCircleLayer {
            sliderCircleLayer.path = isReversed ? circlePath.cgPath : halfSegmentedTempBezierPath.cgPath
            sliderCircleLayer.fillColor = self.viewModel.selectedColor.uiColor.cgColor
            sliderCircleLayer.removeAllAnimations()
            sliderCircleLayer.add(circleAnimation, forKey: "circlePathAnimation")
            if isReversed {
                sliderCircleLayer.add(opacityAnimation, forKey: "circleOpacityAnimation")
            }
        }

        CATransaction.commit()
        
        for (index, animation) in animationArray.enumerated() {
            let index = index
            let translationY = index.double * 5
            
            UIView.animate(withDuration: duration) {
                if isReversed {
                    if index == selectedIndex {
                        animation.view.transform = CGAffineTransform(scaleX: 1.30, y: 1.30).concatenating(CGAffineTransform(translationX: 0, y: -15))
                    } else {
                        animation.view.transform = .identity
                    }
                    self.toolsGradientLayer.transform = CATransform3DIdentity
                } else {
                    if index == selectedIndex {
                        let xDiff = (self.toolsStackView.frame.width-animation.view.frame.width)/2 - animation.view.frame.origin.x
                        animation.view.transform = CGAffineTransform(translationX: xDiff, y: 10).scaledBy(x: 2.0, y: 2.11)
                        self.toolsGradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1.0, y: 2.11).translatedBy(x: .zero, y: -25))
                    } else {
                        let translationX = self.toolsStackView.bounds.width/2
                        let translationY = animation.translationY + translationY.cgFloat
                        animation.view.transform = CGAffineTransform(translationX: translationX, y: translationY)
                    }
                }
            }
            CATransaction.commit()
        }
    }
    
    @objc private func toolTapGestureHandled(_ gesture: UITapGestureRecognizer) {
        guard
            let gestureView = gesture.view,
            let selectedIndex = toolsStackView.arrangedSubviews.firstIndex(of: gestureView)
        else { return }
        
        let index = Int(selectedIndex)
        viewModel.selectBrush(index: index)
    }
    
    
    var isCircleMovingAvailable: Bool = false
    
    @objc private func panGestureHandled(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let sliderCircleLayer else { return }
        let location = gesture.location(in: view)
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            if segmentedControl.frame.insetBy(dx: -8, dy: -8).contains(location) {
                isCircleMovingAvailable = true
            } else {
                isCircleMovingAvailable = false
            }
        case .changed:
            let targetFrame = sliderCircleLayer.frame.withX(sliderCircleLayer.frame.minX + translation.x)
            if isCircleMovingAvailable && (targetFrame.maxX + targetFrame.height / 2) < segmentedControl.frame.maxX && (targetFrame.maxX - targetFrame.height / 2) > segmentedControl.frame.minX {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                sliderCircleLayer.frame = targetFrame
                CATransaction.commit()
                
                let percent = (targetFrame.maxX + targetFrame.height / 2 - segmentedControl.frame.minX) / segmentedControl.frame.width
                print("percent: \(percent)")
                viewModel.updateBrushWidth(percent.float)
            }
        default:
            isCircleMovingAvailable = false
        }
        gesture.setTranslation(.zero, in: view)
    }
}
