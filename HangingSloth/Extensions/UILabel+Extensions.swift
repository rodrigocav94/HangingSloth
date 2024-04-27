//
//  UILabel+Extensions.swift
//  HangingSloth
//
//  Created by Rodrigo Cavalcanti on 27/04/24.
//

import UIKit

extension UILabel {
    func addCharactersSpacing(_ value: CGFloat = 1.15) {
        if let textString = text {
            let attrs: [NSAttributedString.Key : Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
}
