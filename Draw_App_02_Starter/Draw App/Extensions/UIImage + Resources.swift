//
//  UIImage + Resources.swift
//  telegram-contest
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit

extension UIImage{
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    private static var scale: CGFloat {
        return UIScreen.main.scale
    }
    
    static func render(size: CGSize, _ draw: () -> Void) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, .zero)
        defer { UIGraphicsEndImageContext() }
        
        draw()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func make(size: CGSize, color: UIColor = .white) -> UIImage? {
        return render(size: size) {
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
        }
    }
    
    static func generateColorPickerIcon(selectedColor: UIColor) -> UIImage? {

        let imageRect = CGRect(origin: .zero, size: CGSize(size: 33))
        let imageSize = imageRect.size
        
        return render(size: imageSize) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            context.clear(imageRect)
            
            if let cgImage = UIImage(named: "color_picker")?.cgImage {
                context.draw(cgImage, in: imageRect)
            }
            
            let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 4, y: 4), size: CGSize(size: 25)))
            
            context.setFillColor(UIColor.white.cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
            
            let innerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(size: 17)))
            context.setFillColor(selectedColor.cgColor)
            context.addPath(innerPath.cgPath)
            context.fillPath()
        }
    }
    
    static func generateAddIconColorPicker() -> UIImage? {
        self.render(size: CGSize(size: 30)) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.setFillColor(UIColor(hex: "767680")!.withAlphaComponent(0.24).cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(size: 30)))
            if let cgImage = UIImage(named: "add")?.cgImage {
                context.draw(cgImage, in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(size: 30)))
            }
        }
    }
    
    private static let frame = CGRect(size: CGSize(size: 33).scale(scale))
    
    static func generateApplyChangesButtonForTools() -> UIImage? {
        self.render(size: frame.size) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.setFillColor(UIColor(hex: "FFFFFF")!.withAlphaComponent(0.1).cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: 4, y: 4), size: CGSize(width: frame.size.width - 8, height: frame.size.height - 8)))
            if let image = UIImage(systemName: "checkmark.circle", withConfiguration: SymbolConfiguration(scale: .medium)) {
                image.withRenderingMode(.alwaysTemplate).withTintColor(.white).draw(in: frame)
            }
        }?.withRenderingMode(.alwaysOriginal)
    }
    
    static func generateCloseButtonForTools() -> UIImage? {
        self.render(size: frame.size) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.setFillColor(UIColor(hex: "FFFFFF")!.withAlphaComponent(0.1).cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: 4, y: 4), size: CGSize(width: frame.size.width - 8, height: frame.size.height - 8)))
            if let image = UIImage(systemName: "xmark.circle", withConfiguration: SymbolConfiguration(scale: .medium)) {
                image.withRenderingMode(.alwaysTemplate).withTintColor(.white).draw(in: frame)
            }
        }?.withRenderingMode(.alwaysOriginal)
    }
    
    static func generateSizeSliderThumb(size: CGSize) -> UIImage? {
        self.render(size: CGSize(size: 32)) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(size: 30)))
            if let cgImage = UIImage(named: "add")?.cgImage {
                context.draw(cgImage, in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(size: 30)))
            }
        }
    }
    
    static func generateSizeSlider(isRotated: Bool) -> UIImage? {
        let imageRect = CGRect(origin: .zero, size: CGSize(width: 240, height: 25))
        
        return self.render(size: imageRect.size) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            context.setBlendMode(CGBlendMode.softLight)
            context.setFillColor(UIColor(hex: "FFFFFF")!.withAlphaComponent(0.2).cgColor)
            
            let sliderPath = UIBezierPath()
            sliderPath.move(to: CGPoint(x: 0, y: 11.51))
            sliderPath.addCurve(to: CGPoint(x: 1.99, y: 9.43), controlPoint1: CGPoint(x: 0, y: 10.39), controlPoint2: CGPoint(x: 0.88, y: 9.47))
            sliderPath.addLine(to: CGPoint(x: 227.53, y: 0.01))
            sliderPath.addCurve(to: CGPoint(x: 239.5, y: 11.51), controlPoint1: CGPoint(x: 234.06, y: -0.26), controlPoint2: CGPoint(x: 239.5, y: 4.97))
            sliderPath.addCurve(to: CGPoint(x: 227.53, y: 23.01), controlPoint1: CGPoint(x: 239.5, y: 18.05), controlPoint2: CGPoint(x: 234.06, y: 23.28))
            sliderPath.addLine(to: CGPoint(x: 1.99, y: 13.59))
            sliderPath.addCurve(to: CGPoint(x: 0, y: 11.51), controlPoint1: CGPoint(x: 0.88, y: 13.55), controlPoint2: CGPoint(x: 0, y: 12.63))
            sliderPath.close()
            context.addPath(sliderPath.cgPath)
            context.fillPath()
        }
    }
    
    static func generateOpacitySliderTrackImage(color: UIColor) -> UIImage? {
        guard let trackImage = UIImage(named: "opacity_slider_background") else { return nil }
        let trackRect = CGRect(origin: .zero, size: trackImage.size)
        
        return self.render(size: trackRect.size) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
        
            let bezierPath = UIBezierPath(roundedRect: trackRect, cornerRadius: trackRect.height/2)
            context.addPath(bezierPath.cgPath)
            context.clip()

            if let cgImage = trackImage.cgImage {
                context.draw(cgImage, in: trackRect)
            }
            
            var locations: [CGFloat] = [0, 1.0]
            let colors: [CGColor] = [
                color.withAlphaComponent(0),
                color
            ].compactMap({ $0.cgColor })
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: &locations)!
            context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: trackRect.width, y: 0.0), options: CGGradientDrawingOptions())
        }
    }
        
    static func generateToolIcon(name: String, color: UIColor, height: CGFloat? = nil) -> UIImage? {
        var lineWidthFrame: CGRect = .zero
        switch name {
        case "pen":
            lineWidthFrame = CGRect(x: 9, y: 220, width: 1.0, height: height ?? 12)
        case "brush":
            lineWidthFrame = CGRect(x: 9, y: 220, width: 1.0, height: height ?? 12)
        case "neon":
            lineWidthFrame = CGRect(x: 9, y: 196, width: 1.0, height: height ?? 84)
        case "pencil":
            lineWidthFrame = CGRect(x: 9, y: 218, width: 1.0, height: height ?? 48)
        default: break
        }
        return generateToolIcon(name: name, color: color, lineWidthFrame: lineWidthFrame)
    }
    
    static private func generateToolIcon(name: String, color: UIColor, lineWidthFrame: CGRect = .zero) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        
        let imageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        
        return self.render(size: imageRect.size) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.clear(imageRect)
            
            let factor = 1.0
            
            context.translateBy(x: imageRect.size.width / 2.0, y: imageRect.size.height / 2.0)
            context.scaleBy(x: factor, y: -factor)
            context.translateBy(x: -imageRect.size.width / 2.0, y: -imageRect.size.height / 2.0)

            if let cgImage = image.cgImage {
                context.draw(cgImage, in: imageRect)
            }

            context.setFillColor(color.cgColor)
            let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: lineWidthFrame.origin.x, y: imageRect.size.height - lineWidthFrame.origin.y - lineWidthFrame.height),
                                                        size: CGSize(width: imageRect.size.width - lineWidthFrame.origin.x * 2, height: lineWidthFrame.height)), cornerRadius: 6)
            context.addPath(path.cgPath)
            context.fillPath()
            
            if let cgImage = UIImage(named: name + "_tip")?.cgImage {
                context.saveGState()
                context.clip(to: imageRect, mask: cgImage)
                context.setFillColor(color.cgColor)
                context.fill(imageRect)
                context.restoreGState()
            }
        }?.withRenderingMode(.alwaysOriginal)
    }
}
