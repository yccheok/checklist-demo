//
//  UIView+Extensions.swift
//  checklist-demo
//
//  Created by Yan Cheng Cheok on 02/10/2021.
//

import UIKit

extension UIView {
    static func getUINib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
