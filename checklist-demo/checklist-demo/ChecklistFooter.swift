//
//  ChecklistFooter.swift
//  wenote-ios
//
//  Created by Yan Cheng Cheok on 27/09/2021.
//

import UIKit

class ChecklistFooter: UICollectionReusableView {

    var isVisible: Bool {
        set {
            if newValue {
                stackView.isHidden = false
                heightConstraint.constant = 56
            } else {
                stackView.isHidden = true
                heightConstraint.constant = 0
            }
        }
        
        get {
            !stackView.isHidden
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: ViewController?
    
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapped() {
        if !isVisible {
            return
        }
        
        delegate?.checklistFooterClicked()
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        if !isVisible {
            return
        }
        
        delegate?.checklistFooterClicked()
    }
}
