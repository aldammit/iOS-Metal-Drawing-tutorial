//
//  EditorBottomSegementedControl.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit

class EditorBottomSegementedControl: UISegmentedControl {
    
    lazy var backgroundBlur: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let black = UIVisualEffectView(effect: effect)
        return black
    }()
    
    override init(items: [Any]?) {
        super.init(items: items)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        layer.masksToBounds = true
        clipsToBounds = true
        selectedSegmentTintColor = UIColor(hex: "5D5D5D")
        tintColor = UIColor(hex: "5D5D5D")
        setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        insertSubview(backgroundBlur, at: .zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2
        backgroundBlur.frame = bounds
        sendSubviewToBack(backgroundBlur)
    }

    override func addSubview(_ view: UIView) {
        let newBounds = view.layer.bounds.inset(by: UIEdgeInsets(top: 6, left: 7, bottom: 0, right: 0))

        let path = UIBezierPath(roundedRect: newBounds, cornerRadius: newBounds.height / 2)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask

        super.addSubview(view)
    }
}
