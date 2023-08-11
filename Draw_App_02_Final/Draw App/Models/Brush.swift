//
//  Brush.swift
//  Draw App
//
//  Created by Bogdan Redkin on 17/10/2022.
//

import Foundation
import UIKit

struct Brush {
    
    enum Style: String {
        case pen
        case brush
        case neon
        case pencil
        case eraser
    }
    
    let style: Style
    var width: Float
    var color: Color
    
    init(style: Style, width: Float? = nil, color: Color = Color(uiColor: .tintColor)) {
        self.style = style
        self.width = width ?? (style.maxWidth - style.minWidth)/2
        self.color = color
    }
    
}

extension Brush {
    
    var isAvailable: Bool {
        switch style {
        case .eraser, .pen: return true
        default: return false
        }
    }
    
    static func defaultBrushes() -> [Brush] {
        return [
            Brush(style: .pen),
            Brush(style: .brush),
            Brush(style: .neon),
            Brush(style: .pencil),
            Brush(style: .eraser)
        ]
    }
    
    func icon() -> UIImage? {
        return UIImage.generateToolIcon(name: style.rawValue, color: color.uiColor, height: width.cgFloat)
    }
    
    
}

extension Brush.Style {
    var contentScale: Float {
        return (UIApplication.shared.window?.rootViewController?.view.contentScaleFactor ?? 1.0).float
    }
    
    var maxWidth: Float {
        switch self {
        case .eraser:
            return 50 * contentScale
        default:
            return 40 * contentScale
        }
    }
    
    var minWidth: Float {
        switch self {
        case .eraser:
            return 25 * contentScale
        default:
            return 13 * contentScale
        }
    }
}
