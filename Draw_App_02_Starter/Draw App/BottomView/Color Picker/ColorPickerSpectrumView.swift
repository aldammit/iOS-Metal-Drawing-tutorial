//
//  ColorPickerSpectrumView.swift
//  Draw App
//
//  Created by Bogdan Redkin on 18/10/2022.
//

import UIKit

class ColorPickerSpectrumView: UIView {
    
    let viewModel: EditorBottomViewModel
    
    var cgImage: CGImage?
    private var selectorView: UIImageView?
    
    init(viewModel: EditorBottomViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialSetup() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        isExclusiveTouch = true
    }
    
    override var bounds: CGRect {
        didSet {
            setupColorSpectrum()
        }
    }
    
    var colorSelected: ((UIColor) -> Void)?
            
    private func setupColorSpectrum() {
        if let image = generateImage() {
            let imageView = UIImageView(image: image)
            imageView.frame = bounds
            imageView.isUserInteractionEnabled = false
            addSubview(imageView)
        }
    }
    
    func hueAndSaturation(at point: CGPoint) -> (hue: CGFloat, saturation: CGFloat) {
        let hue = 1 - point.y / bounds.height
        let saturation = 1 - point.x / bounds.width
        return (max (0, min(1, hue)), 1 - max(0, min(1, saturation)))
    }
    
    func generateImage() -> UIImage? {
        var imageData = [UInt8](repeating: 1, count: (4 * bounds.width.int * bounds.height.int))
        for i in 0 ..< bounds.width.int {
            for j in 0 ..< bounds.height.int {
                let index = 4 * (i + j * bounds.width.int)
                let (hue, saturation) = hueAndSaturation(at: CGPoint(x: i, y: j))
                let color = Color(hue: hue, saturation: saturation, brightness: 1)
                let (r, g, b, _) = color.uiColor.rgbaCGFloat
                imageData[index] = colorComponentToUInt8(r)
                imageData[index + 1] = colorComponentToUInt8(g)
                imageData[index + 2] = colorComponentToUInt8(b)
                imageData[index + 3] = 255
            }
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let data = Data(imageData)
        let mutableData = UnsafeMutableRawPointer.init(mutating: (data as NSData).bytes)
        let context = CGContext(data: mutableData, width: bounds.width.int, height: bounds.height.int, bitsPerComponent: 8, bytesPerRow: 4 * bounds.width.int, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)
        guard let cgImage = context?.makeImage() else {
            return nil
        }
        self.cgImage = cgImage

        return UIImage(cgImage: cgImage)
    }
    
    func colorComponentToUInt8(_ component: CGFloat) -> UInt8 {
        return UInt8(max(0, min(255, round(255 * component))))
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if frame.contains(point)  {
            return true
        } else {
            return super.point(inside: point, with: event)
        }
    }
            
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")

        rootSuperView?.firstSubview(of: UIScrollView.self)?.panGestureRecognizer.isEnabled = false
        rootSuperView?.firstSubview(of: ColorPickerBottomSheetView.self)?.gestureRecognizers?.forEach({ $0.isEnabled = false })

        if selectorView == nil, let location = touches.randomElement()?.location(in: self) {
            selectorView = UIImageView(image: UIImage(named: "opacity_slider_thumb"))
            selectorView?.frame = CGRect(center: location, size: CGSize(size: 29))
            selectorView?.isUserInteractionEnabled = false
            addSubview(selectorView!)
        }
    }
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.randomElement()?.location(in: self.superview), let cgImage, location.x > 0, location.y > 0 else { return }
        if let (r, g, b) = cgImage.pixel(x: location.x.int, y: location.y.int) {
            self.selectorView?.frame = CGRect(center: location, size: CGSize(size: 29))
            let color = UIColor(red: r.cgFloat / 255, green: g.cgFloat / 255, blue: b.cgFloat / 255, alpha: 1)
            self.viewModel.updateValuesInColorPicker(color: Color(uiColor: color), source: .spectrum)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        rootSuperView?.firstSubview(of: UIScrollView.self)?.panGestureRecognizer.isEnabled = true
        rootSuperView?.firstSubview(of: ColorPickerBottomSheetView.self)?.gestureRecognizers?.forEach({ $0.isEnabled = true })
    }
    
    
}
