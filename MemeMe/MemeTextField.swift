//
//  MemeTextField.swift
//  MemeMe
//
//  Created by Luis Vega on 1/19/17.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit

class MemeTextField: UITextField {
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -5,
        ]
    
    var isPristine = true
    var originalText : String!
    
    override func awakeFromNib() {
        defaultTextAttributes = memeTextAttributes
        textAlignment = NSTextAlignment.center
        originalText = text
    }
    
    func restorePristine() {
        isPristine = true
        text = originalText
    }
    
}
