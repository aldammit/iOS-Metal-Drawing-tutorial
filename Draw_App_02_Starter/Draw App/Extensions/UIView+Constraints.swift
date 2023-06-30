//
//  UIView + Constraints.swift
//  telegram-contest
//
//  Created by Bogdan Redkin on 12/10/2022.
//

import UIKit

extension UIView {
    
    enum Edge {
        case top
        case leading
        case trailing
        case bottom
    }
        
    func forAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func pinToSuperviewEdgesWithInsets(
        _ insets: UIEdgeInsets,
        respectingSafeArea: Bool = false
    ) {
        guard let superview = self.superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false
        let topTarget = respectingSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor
        let bottomTarget = respectingSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor
        let leftTarget = respectingSafeArea ? superview.safeAreaLayoutGuide.leadingAnchor : superview.leadingAnchor
        let rightTarget = respectingSafeArea ? superview.safeAreaLayoutGuide.trailingAnchor : superview.trailingAnchor
        NSLayoutConstraint.activate(
            [
                self.topAnchor.constraint(equalTo: topTarget, constant: insets.top),
                self.leadingAnchor.constraint(equalTo: leftTarget, constant: insets.left),
                self.trailingAnchor.constraint(equalTo: rightTarget, constant: -insets.right),
                self.bottomAnchor.constraint(equalTo: bottomTarget, constant: -insets.bottom)
            ]
        )
    }

    func pinToSuperviewEdgesWithInsets(
        top: CGFloat? = nil,
        left: CGFloat? = nil,
        right: CGFloat? = nil,
        bottom: CGFloat? = nil,
        respectingSafeArea: Bool = false
    ) {
        guard let superview = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let topInset = top {
            let target = respectingSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor
            layoutConstraints.append(self.topAnchor.constraint(equalTo: target, constant: topInset))
        }
        
        if let leftInset = left {
            let target = respectingSafeArea ? superview.safeAreaLayoutGuide.leadingAnchor : superview.leadingAnchor
            layoutConstraints.append(self.leadingAnchor.constraint(equalTo: target, constant: leftInset))
        }
        
        if let rightInset = right {
            let target = respectingSafeArea ? superview.safeAreaLayoutGuide.trailingAnchor : superview.trailingAnchor
            layoutConstraints.append(self.trailingAnchor.constraint(equalTo: target, constant: -rightInset))
        }
        
        if let bottomInset = bottom {
            let target = respectingSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor
            layoutConstraints.append(self.bottomAnchor.constraint(equalTo: target, constant: -bottomInset))
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func pinToSuperviewEdges(exclude edge: Edge? = nil, respectingSafeArea: Bool = false) {
        self.pinToSuperviewEdgesWithInsets(
            top: edge == .top ? nil : .zero,
            left: edge == .leading ? nil : .zero,
            right: edge == .trailing ? nil : .zero,
            bottom: edge == .bottom ? nil : .zero,
            respectingSafeArea: respectingSafeArea
        )
    }
        
    func addSubviewPinnedToEdges(_ subview: UIView, respectingSafeArea: Bool = false) {
        subview.frame = self.bounds
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        if respectingSafeArea {
            NSLayoutConstraint.activate(
                [
                    subview.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
                    subview.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
                    subview.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
                    subview.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
                ]
            )
        } else {
            self.pinToSuperviewEdges()
        }
    }
    
    func alignCenter(to targetView: UIView) {
        NSLayoutConstraint.activate(
            [
                self.centerXAnchor.constraint(equalTo: targetView.centerXAnchor),
                self.centerYAnchor.constraint(equalTo: targetView.centerYAnchor)
            ]
        )
    }
    
    func alignSize(to size: CGSize) {
        NSLayoutConstraint.activate(
            [
                self.heightAnchor.constraint(equalToConstant: size.height),
                self.widthAnchor.constraint(equalToConstant: size.width)
            ]
        )
    }
}
