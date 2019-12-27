//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 25/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit
extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
    }
    var coordinates: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    }
    
    func checkEquivalentCoordinates (coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longitude == coordinate.longitude)
    }
}
