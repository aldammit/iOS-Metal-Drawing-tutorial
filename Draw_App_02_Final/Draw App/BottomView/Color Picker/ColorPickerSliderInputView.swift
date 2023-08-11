//
//  ColorPickerOpacitySelectionView.swift
//  Draw App
//
//  Created by Bogdan Redkin on 20/10/2022.
//

import UIKit

class ColorPickerSliderInputView: UIView {

    private(set) lazy var opacityTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textField.text = "100%"
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.tintColor = .white
        textField.textColor = .white
        textField.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .black
        
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonHandler))
        doneItem.tintColor = UIColor.white
        toolbar.items = [spaceItem, doneItem]
        toolbar.sizeToFit()
        
        textField.inputAccessoryView = toolbar
        
        return textField
    }()

    private(set) lazy var opacitySlider: ColorPickerSlider = {
        let slider = ColorPickerSlider(frame: .zero)
        return slider
    }()
    private var opacityValue: Int {
        return Int.extract(from: opacityTextField.text ?? "0%") ?? 0
    }
    
    private weak var scrollView: UIScrollView?
    private var opacityValueUpdated: ((Int) -> Void)?
    
    init(scrollView: UIScrollView, frame: CGRect = .zero, opacityValueUpdated: ((Int) -> Void)?) {
        self.scrollView = scrollView
        self.opacityValueUpdated = opacityValueUpdated
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(opacitySlider)
        addSubview(opacityTextField)
        
        setupLayout()
    }
    
    private func setupLayout() {
        opacitySlider.pinToSuperviewEdgesWithInsets(left: 16)
        opacityTextField.pinToSuperviewEdgesWithInsets(right: 16)
        opacityTextField.alignSize(to: CGSize(width: 77, height: 36))
        
        NSLayoutConstraint.activate([
            opacitySlider.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            opacitySlider.rightAnchor.constraint(equalTo: opacityTextField.leftAnchor, constant: -12),
            opacitySlider.heightAnchor.constraint(equalToConstant: 36),
            opacitySlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            opacityTextField.topAnchor.constraint(equalTo: opacitySlider.topAnchor)
        ])
    }

    @objc private func doneButtonHandler() {
        endEditing(true)
        if opacityValue > 100 {
            opacityTextField.text = "100%"
        }
        opacityValueUpdated?(opacityValue)
        opacitySlider.value = opacityValue.float/100
    }
}

extension ColorPickerSliderInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.text != nil else { return false }
        
        if Int.extract(from: string) != nil {
            return true
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let selectedTextRange = textField.selectedTextRange else { return }
        
        if selectedTextRange.end == textField.endOfDocument {
            guard let targetPos = textField.position(from: textField.endOfDocument, offset: -1) else { return }
            textField.selectedTextRange = textField.textRange(from: targetPos, to: targetPos)
        }
    }
}
