//
//  Color.swift
//  Draw App
//
//  Created by Bogdan Redkin on 20/10/2022.
//

import UIKit

struct Color: Codable {
        
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    var hex: String {
        uiColor.hexString
    }
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
        
    var hue: CGFloat {
        get { uiColor.hsba.h }
        set {
            var (h,s,b,a) = uiColor.hsba
            h = newValue
            let (r, g, blue, _) = UIColor(hue: h, saturation: s, brightness: b, alpha: a).rgbaCGFloat
            self.red = r
            self.green = g
            self.blue = blue
        }
    }
    
    var saturation: CGFloat {
        get { uiColor.hsba.s }
        set {
            var (h,s,b,a) = uiColor.hsba
            s = newValue
            let (r, g, blue, _) = UIColor(hue: h, saturation: s, brightness: b, alpha: a).rgbaCGFloat
            self.red = r
            self.green = g
            self.blue = blue
        }
    }
    
    var brightness: CGFloat {
        get { uiColor.hsba.b }
        set {
            var (h, s, b, a) = uiColor.hsba
            b = newValue
            let (r, g, blue, _) = UIColor(hue: h, saturation: s, brightness: b, alpha: a).rgbaCGFloat
            self.red = r
            self.green = g
            self.blue = blue
        }
    }
        
    init(uiColor: UIColor) {
        let (r, g, b, a) = uiColor.rgbaCGFloat
        red = r
        green = g
        blue = b
        alpha = a
    }
    
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1) {
        let h = max(0, min(1, hue))
        let s = max(0, min(1, saturation))
        let b = max(0, min(1, brightness))
        let a = max(0, min(1, alpha))
        let uiColor = UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        self.init(uiColor: uiColor)
    }
        
    init(hue: Int, saturation: Int, brightness: Int, alpha: CGFloat = 1) {
        self.init(hue: hue.cgFloat/359, saturation: saturation.cgFloat/100, brightness: brightness.cgFloat/100, alpha: alpha)
    }
    
    func save() {
        var array = Color.fetchSavedColors()
        array.append(self)
        if let encodedArray = try? JSONEncoder().encode(array),
           let string = String(data: encodedArray, encoding: .utf8) {
            UserDefaults.standard.set(string, forKey: "saved_colors")
        }
    }
    
    static func fetchSavedColors() -> [Color] {
        if let savedArray = UserDefaults.standard.string(forKey: "saved_colors"),
           let data = savedArray.data(using: .utf8),
           let decodedArray = try? JSONDecoder().decode([Color].self, from: data)
        {
            return decodedArray
        } else {
            return []
        }
    }
    
    static func defaultPalette() -> [Color] {
        return [
            UIColor.black,
            UIColor.systemBlue,
            UIColor.systemRed,
            UIColor.systemOrange
        ].map { Color(uiColor: $0) }
    }
}
