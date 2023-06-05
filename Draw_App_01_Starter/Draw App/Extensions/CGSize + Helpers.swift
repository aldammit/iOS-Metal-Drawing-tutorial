//
//  CGSize + Helpers.swift
//  Draw App
//
//  Created by Bogdan Redkin on 11/10/2022.
//

import Foundation

extension CGSize {
    
    init(size: CGFloat) {
        self.init(width: size, height: size)
    }
    
    func interpolate(to: CGSize, progress: CGFloat) -> CGSize {
        guard progress >= 0.0 && progress <= 1.0 else { return self }
        
        let width = self.width.interpolate(to: to.width, progress: progress)
        let height = self.height.interpolate(to: to.height, progress: progress)
        return CGSize(width: width, height: height)
    }
    
    func scale(_ factor: CGFloat) -> CGSize {
        let transform = CGAffineTransform(scaleX: factor, y: factor)
        return self.applying(transform)
    }
        
    static func *(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: rhs.width * lhs, height: rhs.height * lhs)
    }
    
    static func /(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}
