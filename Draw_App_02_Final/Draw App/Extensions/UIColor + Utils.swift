//
//  UIColor + Hex.swift
//  Draw App
//
//  Created by Bogdan Redkin on 10/10/2022.
//

import UIKit
import simd

extension UIColor {
    
    public convenience init?(hex: String) {
        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)

        let red = CGFloat((hexInt & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xFF) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    var hexString: String {
        let (r, g, b, _) = rgbaCGFloat
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
    typealias RGBA<T: FloatingPoint> = (r: T, g: T, b: T, a: T)
    
    var rgbaCGFloat: RGBA<CGFloat> {
        var r: CGFloat = .zero
        var g: CGFloat = .zero
        var b: CGFloat = .zero
        var a: CGFloat = .zero
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    var rgbaDouble: RGBA<Double> {
        let (r,g,b,a) = rgbaCGFloat
        return (r.double, g.double, b.double, a.double)
    }
    
    var vectorFloat4: vector_float4 {
        let (r,g,b,a) = rgbaDouble
        return vector_float4(r.float, g.float, b.float, a.float)
    }
    
    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = .zero
        var s: CGFloat = .zero
        var b: CGFloat = .zero
        var a: CGFloat = .zero
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
}
