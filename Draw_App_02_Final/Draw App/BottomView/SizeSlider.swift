//
//  SizeSlider.swift
//  Draw App
//
//  Created by Bogdan Redkin on 26/10/2022.
//

import Foundation
import UIKit

class SizeSlider: UISlider {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    private func initialSetup() {
        if let trackImage = UIImage.generateSizeSlider(isRotated: true) {
            self.setMaximumTrackImage(trackImage, for: .normal)
            self.setMinimumTrackImage(trackImage, for: .normal)
        }
        
        if let thumbImage = UIImage.generateSizeSliderThumb(size: CGSize(width: 32, height: 32)) {
            self.setThumbImage(thumbImage, for: .normal)
        }
        value = 0.5
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.size.height = 24
        result.origin = .zero
        return result
    }
    
    func runTransitionAnimation(from segmentedControl: EditorBottomSegementedControl) {
        layer.sublayers?.forEach({ $0.isHidden = true })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        var sliderTransforms = self.transform
        sliderTransforms = sliderTransforms.concatenating(CGAffineTransform(translationX: 20, y: .zero))
        UIView.animate(withDuration: 0.2, delay: .zero) {
            self.transform = sliderTransforms
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        var sliderTransforms = self.transform
        sliderTransforms = sliderTransforms.concatenating(CGAffineTransform(translationX: -20, y: .zero))
        UIView.animate(withDuration: 0.2, delay: .zero) {
            self.transform = sliderTransforms
        }
    }
}
