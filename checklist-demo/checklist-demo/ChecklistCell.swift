//
//  ChecklistCell.swift
//  checklist-demo
//
//  Created by Yan Cheng Cheok on 02/10/2021.
//

import UIKit

class ChecklistCell: UICollectionViewCell {

    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: ViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Remove all padding for UITextView.
        // https://stackoverflow.com/questions/15823991/ios-remove-all-padding-from-uitextview
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
    }

    func update(_ checklist: Checklist) {
        textView.text = checklist.text
    }
}

extension ChecklistCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(self)
    }
}
