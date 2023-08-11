//
//  CGRect + Helpers.swift
//  Draw App
//
//  Created by Bogdan Redkin on 11/10/2022.
//

import Foundation

extension CGRect {
    
    public init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }

    func scale(_ factor: CGFloat) -> CGRect {
        let transform = CGAffineTransform(scaleX: factor, y: factor)
        return self.applying(transform)
    }
    
    func interpolate(to: CGRect, progress: CGFloat) -> CGRect {
        guard progress >= 0.0, progress <= 1.0 else { return self }
        let origin = origin.interpolate(to: to.origin, progress: progress)
        let size = size.interpolate(to: to.size, progress: progress)
        return CGRect(origin: origin, size: size)
    }
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
    }
    
    func withOrigin(_ newOrigin: CGPoint) -> CGRect {
        var newRect = self
        newRect.origin = newOrigin
        return newRect
    }
    
    func withX(_ newX: CGFloat) -> CGRect {
        return withOrigin(CGPoint(x: newX, y: minY))
    }
    
    func withY(_ newY: CGFloat) -> CGRect {
        return withOrigin(CGPoint(x: minX, y: newY))
    }
    
    func withSize(_ newValue: CGSize) -> CGRect {
        var newRect = self
        newRect.size = newValue
        return newRect
    }
    
    func withWidth(_ newWidth: CGFloat) -> CGRect {
        return withSize(CGSize(width: newWidth, height: height))
    }
    
    
    func withHeight(_ newHeight: CGFloat) -> CGRect {
        return withSize(CGSize(width: width, height: newHeight))
    }
}
