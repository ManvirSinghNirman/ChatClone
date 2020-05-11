//
//  Empty.swift
//  InteractiveDemo
//
//  Created by sierra on 07/03/19.
//  Copyright © 2019 sierra. All rights reserved.
//

import UIKit

class Empty: FlexibleView {

     
    @IBOutlet weak var btnSend :UIButton!
    @IBOutlet weak var btnAttachnent :UIButton!
    @IBOutlet weak var txtView :FlexibleTextView!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        txtView.maxHeight = 150
        autoresizingMask = .flexibleHeight
    }

}

class FlexibleView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
