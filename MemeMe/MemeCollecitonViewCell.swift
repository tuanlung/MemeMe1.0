//
//  MemeCollecitonViewCell.swift
//  MemeMe
//
//  Created by Tuan-Lung Wang on 5/30/17.
//  Copyright © 2017 Tuan-Lung Wang. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var verticalConstraintForTopLabel: NSLayoutConstraint!

    @IBOutlet weak var verticalConstraintForBottomLabel: NSLayoutConstraint!
}
