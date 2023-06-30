//
//  ColorPaletteCollectionViewCell.swift
//  Draw App
//
//  Created by Bogdan Redkin on 20/10/2022.
//

import UIKit

class ColorPaletteCollectionViewCell: UICollectionViewCell {
    
    var item: CollorPickerBottomSheetController.Item?
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setup(with item: CollorPickerBottomSheetController.Item) {
        self.item = item
        switch item {
        case .add:
            imageView?.isHidden = false
            contentView.backgroundColor = .clear
        case .paletteItem(let item):
            contentView.backgroundColor = item.color.uiColor
            imageView?.isHidden = true
        }
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = UIColor.white.cgColor
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 0
        }
    }
        
    private func setupViews() {
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        imageView = UIImageView(frame: bounds)
        imageView?.image = UIImage.generateAddIconColorPicker()
        contentView.addSubviewPinnedToEdges(imageView!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.isHidden = true
    }

}
