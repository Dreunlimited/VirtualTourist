//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 2/26/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkedImageView: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var editing:Bool = false {
        didSet {
            checkedImageView.isHidden = !editing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if editing {
                checkedImageView.image = UIImage(named: isSelected ? "Checked" : "Unchecked")
            }
        }
    }
    
}
