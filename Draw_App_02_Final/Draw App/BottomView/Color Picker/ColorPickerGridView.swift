//
//  ColorPickerView.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import UIKit
import Combine

class ColorPickerGridView: UIView {
    
    let viewModel: EditorBottomViewModel
    
    init(viewModel: EditorBottomViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        if viewModel.selectedColorSource == .grid {
            selectedColor = viewModel.selectedColor.uiColor
        }
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        addGestureRecognizer(tapGesture)
    }
    
    override var bounds: CGRect {
        didSet {
            setupColorGrid()
        }
    }
        
    private var selectedColor: UIColor?
    private var grids: [UIView] = []
        
    private func setupColorGrid() {
        grids.forEach({ $0.removeFromSuperview() })
        grids.removeAll()
        
        let widthCount = 12
        let heightCount = 10
        let size = CGSize(width: frame.width/12, height: frame.height/10)
        
        let initialColors: [Color] = [
            Color(hue: 195, saturation: 100, brightness: 29),
            Color(hue: 220, saturation: 99, brightness: 34),
            Color(hue: 253, saturation: 92, brightness: 23),
            Color(hue: 284, saturation: 90, brightness: 24),
            Color(hue: 337, saturation: 88, brightness: 24),
            Color(hue: 4, saturation: 99, brightness: 36),
            Color(hue: 19, saturation: 100, brightness: 35),
            Color(hue: 35, saturation: 100, brightness: 35),
            Color(hue: 43, saturation: 100, brightness: 34),
            Color(hue: 57, saturation: 100, brightness: 40),
            Color(hue: 64, saturation: 95, brightness: 33),
            Color(hue: 91, saturation: 76, brightness: 24)
        ]
        
        let finalColors: [Color] = [
            Color(hue: 197, saturation: 20, brightness: 100),
            Color(hue: 218, saturation: 17, brightness: 100),
            Color(hue: 257, saturation: 21, brightness: 100),
            Color(hue: 283, saturation: 20, brightness: 100),
            Color(hue: 339, saturation: 15, brightness: 98),
            Color(hue: 3, saturation: 15, brightness: 100),
            Color(hue: 18, saturation: 16, brightness: 100),
            Color(hue: 34, saturation: 17, brightness: 100),
            Color(hue: 41, saturation: 16, brightness: 100),
            Color(hue: 56, saturation: 13, brightness: 99),
            Color(hue: 68, saturation: 12, brightness: 98),
            Color(hue: 97, saturation: 11, brightness: 93)
        ]
        
        for widthIndex in 0..<widthCount {
            for heightIndex in 0..<heightCount {
                let frame = CGRect(x: widthIndex.cgFloat * size.width, y: heightIndex.cgFloat * size.height, width: size.width, height: size.height)
                let gridView = UIView(frame: frame)
                if heightIndex == 0 {
                    if widthIndex == widthCount - 1 {
                        gridView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
                    } else {
                        gridView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: (20 + ((widthCount.cgFloat - 1) - widthIndex.cgFloat) * 8)/100, alpha: 1)
                    }
                } else {
                    var color = initialColors[widthIndex]
                    let resultColor = finalColors[widthIndex]
                                                                      
                    let saturation = 1 - max(0, min(1, (heightIndex.cgFloat - 5)/4))

                    let brightness = max(0, min(1, (heightIndex.cgFloat - 1)/5))
                    
                    if heightIndex > 5 {
                        color.saturation = saturation * (color.saturation - resultColor.saturation) + resultColor.saturation
                    }
                    color.brightness = brightness * (resultColor.brightness - color.brightness) + color.brightness
                    
                    gridView.backgroundColor = color.uiColor
                }
                self.addSubview(gridView)
                grids.append(gridView)
            }
        }
    }
    
    @objc private func tapGesture(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        grids.filter({ $0.frame.contains(location) }).forEach {
            self.selectedColor = $0.backgroundColor
            self.makeGridViewSelected(view: $0)
            if let selectedColor = $0.backgroundColor {
                self.viewModel.updateValuesInColorPicker(color: Color(uiColor: selectedColor), source: .grid)
            }
        }
    }
    
    private func makeGridViewSelected(view: UIView) {
        grids.forEach({
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.layer.borderWidth = 0
            $0.transform = .identity
            $0.layer.cornerRadius = 0
        })
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.white.cgColor
        let scale = 3/view.bounds.width
        view.transform = CGAffineTransform(scaleX: 1 + scale, y: 1 + scale)
        bringSubviewToFront(view)
    }
}
