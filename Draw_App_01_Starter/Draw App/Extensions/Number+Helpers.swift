//
//  Number+Helpers.swift
//  Draw App
//
//  Created by Bogdan Redkin on 11/10/2022.
//

import Foundation

extension Int {
    func interpolate(to: Int, progress: CGFloat) -> Int {
        guard progress >= 0.0 && progress <= 1.0 else { return self }
        return self + Int(CGFloat(to - self) * progress)
    }
    
    var int32: UInt32 {
        return UInt32(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    var double: Double {
        return Double(self)
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var string: String {
        return String(describing: self)
    }
    
    static func extract(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

extension Float {
    
    var int: Int {
        return Int(self)
    }
    
    var int32: UInt32 {
        return UInt32(self)
    }
    
    var double: Double {
        return Double(self)
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var string: String {
        return String(describing: self)
    }
}

extension Double {
    var float: Float {
        return Float(self)
    }
    
    var int: Int {
        return Int(self)
    }

    var int32: UInt32 {
        return UInt32(self)
    }

    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var string: String {
        return String(describing: self)
    }
}

let π = CGFloat.pi

extension CGFloat {
    func interpolate(to: CGFloat, progress: CGFloat) -> CGFloat {
        guard progress >= 0.0 && progress <= 1.0 else { return self }
        return self + (to - self) * progress
    }
    
    var int: Int {
        return Int(self)
    }
    
    var int32: UInt32 {
        return UInt32(self)
    }
    
    var double: Double {
        return Double(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    var string: String {
        return String(describing: self)
    }
    // Converts an angle in degrees to radians.
    func degreesToRadians() -> CGFloat {
      
      return π * self / 180.0
    }

    // Converts an angle in radians to degrees.
    func radiansToDegrees() -> CGFloat {
      return self * 180.0 / π
    }

    // Ensures that the float value stays between the given values, inclusive.
    func clamped(_ v1: CGFloat, _ v2: CGFloat) -> CGFloat {
      let min = v1 < v2 ? v1 : v2
      let max = v1 > v2 ? v1 : v2
      return self < min ? min : (self > max ? max : self)
    }

    // Ensures that the float value stays between the given values, inclusive.
    mutating func clamp(_ v1: CGFloat, _ v2: CGFloat) -> CGFloat {
      self = clamped(v1, v2)
      return self
    }

    // Returns 1.0 if a floating point value is positive; -1.0 if it is negative.
    func sign() -> CGFloat {
      return (self >= 0.0) ? 1.0 : -1.0
    }

    func rounded(symbolsAfterComma count: Int) -> CGFloat {
        let multiplier = pow(10, count.double).cgFloat
        let result = (self * multiplier).rounded() / multiplier
        return result
    }
}

extension UInt32 {
    var float: Float {
        return Float(self)
    }
    
    var int: Int {
        return Int(self)
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var string: String {
        return String(describing: self)
    }
}
