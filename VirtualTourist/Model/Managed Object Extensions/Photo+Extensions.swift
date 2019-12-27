//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 25/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    func saveImage(image: UIImage) {
        self.image = image.pngData()
    }
    
    func fetchImage() -> UIImage? {
        return (image == nil) ? nil : UIImage(data: image!)
    }
}

