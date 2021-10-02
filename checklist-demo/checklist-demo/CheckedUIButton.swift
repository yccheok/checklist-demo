//
//  CheckedUIButton.swift
//  wenote-ios
//
//  Created by Yan Cheng Cheok on 24/09/2021.
//

import UIKit

// https://stackoverflow.com/a/69310669/72437
class CheckedUIButton: UIButton {

    var checked: Bool = false {
        didSet {
            if checked {
                setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .default)), for: .normal)
            } else {
                setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(scale: .default)), for: .normal)
            }
        }
    }
    
    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
     
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        addTarget(self, action: #selector(self.checkedTapped), for: .touchUpInside)
    }

    @objc
    private func checkedTapped() {
        self.checked.toggle()
    }
}
