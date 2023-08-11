//
//  ColorPickerSlider.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit

class ColorPickerSlider: UISlider {

    private var currentColor: Color?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    private func initialSetup() {
        if let trackImage = UIImage.generateOpacitySliderTrackImage(color: .black) {
            self.setMaximumTrackImage(trackImage, for: .normal)
            self.setMinimumTrackImage(trackImage, for: .normal)
        }
        setThumbImage(UIImage(named: "opacity_slider_thumb"), for: .normal)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.size.height = 36
        result.origin = .zero
        return result
    }
    
    func updateSelectedColor(color: Color) {
        if value.cgFloat != color.alpha {
            value = color.alpha.float
        }
        if let currentColor, currentColor.hex == color.hex {
            return
        }
        currentColor = color
        if let trackImage = UIImage.generateOpacitySliderTrackImage(color: color.uiColor) {
            self.setMaximumTrackImage(trackImage, for: .normal)
            self.setMinimumTrackImage(trackImage, for: .normal)
        }
    }
}
