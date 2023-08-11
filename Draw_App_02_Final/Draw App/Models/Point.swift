//
//  Point.swift
//  Draw App
//
//  Created by Bogdan Redkin on 07/05/2023.
//

import Foundation
import simd
import UIKit

struct TextureVertex {
    var position: vector_float2
    var texcoord: vector_float2
    
    init(position: vector_float2, texcoord: vector_float2) {
        self.position = position
        self.texcoord = texcoord
    }
    
    init?(corner: UIRectCorner) {
        switch corner {
        case .topLeft:
            self.init(position: .init(x: -1.0, y: 1.0), texcoord: .init(0.0, 0.0))
        case .topRight:
            self.init(position: .init(x: 1.0, y: 1.0), texcoord: .init(1.0, 0.0))
        case .bottomLeft:
            self.init(position: .init(x: -1, y: -1), texcoord: .init(0.0, 1.0))
        case .bottomRight:
            self.init(position: .init(x: 1, y: -1), texcoord: .init(1.0, 1.0))
        default:
            return nil
        }
    }
}

struct Point {
    var position: vector_float4
    var color: vector_float4
    var size: Float

    init(position: vector_float4, color: vector_float4, size: Float) {
        self.position = position
        self.color = color
        self.size = size
    }

    init(x: CGFloat, y: CGFloat, color: UIColor, size: CGFloat) {
        self.init(position: vector_float4(Float(x), Float(y), 0, 1), color: color.vectorFloat4, size: Float(size))
    }

    init(location: CGPoint, parentSize: CGSize, color: UIColor, size: CGFloat) {
        let roundedLocation = CGPoint(x: location.x.int.cgFloat, y: location.y.int.cgFloat)
        let xK = (1.0 / (parentSize.width / roundedLocation.x)).rounded(symbolsAfterComma: 5)
        let yK = (1.0 / (parentSize.height / roundedLocation.y)).rounded(symbolsAfterComma: 5)
        let x = xK == 0.5 ? 0.0 : (xK < 0.5 ? -(1 - xK / 0.5) : xK / 0.5 - 1)
        let y = yK == 0.5 ? 0.0 : (yK > 0.5 ? (1 - yK / 0.5) : 1 - (yK / 0.5))
        self.init(x: x, y: y, color: color, size: size)
    }
}
