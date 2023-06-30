//
//  UIView + Helpers.swift
//  telegram-contest
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit

extension UIView {
    
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
        
    var rootSuperView: UIView? {
        if superview?.superview == nil {
            return superview
        } else {
            return superview?.rootSuperView
        }
    }

    var recursiveAllSubviews: [UIView] {
        subviews + subviews.flatMap { $0.recursiveAllSubviews }
    }
    
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        recursiveAllSubviews.first { $0 is T } as? T
    }
    
    func findFirstResponder() -> UIView? {
        for subview in subviews {
            if subview.isFirstResponder {
                return subview
            }
            
            if let recursiveSubView = subview.findFirstResponder() {
                return recursiveSubView
            }
        }

        return nil
    }
}
