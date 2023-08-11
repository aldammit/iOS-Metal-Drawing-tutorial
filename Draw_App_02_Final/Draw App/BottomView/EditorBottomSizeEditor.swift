//
//  EditorBottomSizeEditor.swift
//  Draw App
//
//  Created by Bogdan Redkin on 29/10/2022.
//

import UIKit

class EditorBottomSizeEditor: UIView {
    var brushImageView: UIImageView?
    var sizeSlider: SizeSlider?
    var brushTypeButton: UIButton?
    var backButton: UIButton?
    
    var selectedBrush: Brush
    let viewModel: EditorBottomViewModel
    
    init(selectedBrush: Brush, viewModel: EditorBottomViewModel, frame: CGRect) {
        self.selectedBrush = selectedBrush
        self.viewModel = viewModel
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        brushImageView = UIImageView(frame: CGRect(origin: CGPoint(x: (bounds.width - 40) / 2 , y: .zero), size: CGSize(width: 40, height: 120)))
        brushImageView?.contentMode = .scaleAspectFit
        brushImageView?.image = selectedBrush.icon()
        addSubview(brushImageView!)
        
        sizeSlider = SizeSlider(frame: CGRect(origin: CGPoint(x: 46.5 , y: brushImageView!.frame.maxY), size: CGSize(width: bounds.width-134, height: 28)))
        sizeSlider?.value = selectedBrush.width
        sizeSlider?.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSubview(sizeSlider!)
        
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        print("slider value changed: \(slider.value)")
    }
}
