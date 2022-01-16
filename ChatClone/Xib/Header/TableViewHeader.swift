//
//  TableViewHeader.swift
//  ChatClone
//
//  Created by Manvir Nirmaan on 2022-01-15.
//  Copyright © 2022 Manvir Singh. All rights reserved.
//

import Foundation
import UIKit

class TableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblDate :UILabel!

    override func awakeFromNib() {
        self.contentView.backgroundColor = .clear //Or any color you want

    }
}
