//
//  FlexibleTextView.swift
//  InputAccessoryView
//
//  Created by Satnam Sync on 5/19/18.
//  Copyright © 2018 Satnam Sync. All rights reserved.
//

import Foundation
import UIKit

class FlexibleTextView: UITextView {
    // limit the height of expansion per intrinsicContentSize
    var maxHeight: CGFloat = 200.0
    private let placeholderTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.gray
        return tv
    }()

    var isMaxLimitEnable: Bool = true

    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        
        isScrollEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholderTextView.font = font
        addSubview(placeholderTextView)
        
        NSLayoutConstraint.activate([
            placeholderTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderTextView.topAnchor.constraint(equalTo: topAnchor),
            placeholderTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    
    override var contentInset: UIEdgeInsets {
        didSet {
            placeholderTextView.contentInset = contentInset
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        if size.height == UIView.noIntrinsicMetric {
            // force layout
            layoutManager.glyphRange(for: textContainer)
            size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
        }
        
        if maxHeight > 0.0 && size.height > maxHeight {
            size.height = maxHeight
            
            if !isScrollEnabled {
                isScrollEnabled = true
            }
        } else if isScrollEnabled {
            isScrollEnabled = false
        }
        
        return size
    }
    
     func textDidChange() {
        // needed incase isScrollEnabled is set to true which stops automatically calling invalidateIntrinsicContentSize()
        invalidateIntrinsicContentSize()
    }
}

extension UITextView {
    var numberOfLines: Int {
        // Get number of lines
        let numberOfGlyphs = self.layoutManager.numberOfGlyphs
        var index = 0, numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)

        while index < numberOfGlyphs {
            self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
          index = NSMaxRange(lineRange)
          numberOfLines += 1
        }

        return numberOfLines
    }
}


