//
//  MapAnnotation.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import UIKit
import MapKit
import SwiftUI

public class MapAnnotation: NSObject, MKAnnotation {
    
    public var locationInfo : MapLocation {
        didSet {
            coordinate = locationInfo.coordinates
        }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        didSet {
            locationInfo.coordinates = coordinate
        }
    }
    
    init(location:MapLocation) {
        locationInfo = location
        coordinate = location.coordinates
    }

}
