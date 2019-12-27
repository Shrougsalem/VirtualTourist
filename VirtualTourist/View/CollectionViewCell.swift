//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 24/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import Kingfisher


class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var photo: Photo! {
        didSet{
            if let image = photo.fetchImage() {
                imageView.image = image
            } else if let url = photo.url {
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: url, options:[.transition(.fade(0.5))])
            }
        }
    }
    
}
