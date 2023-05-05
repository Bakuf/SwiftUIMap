//
//  MapAnnotation.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import UIKit
import MapKit

public class MapAnnotation: NSObject, MKAnnotation {
    
    public var locationInfo : MapLocation {
        didSet {
            title = locationInfo.name
            coordinate = locationInfo.coordinates
        }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        didSet {
            locationInfo.coordinates = coordinate
        }
    }
    
    public var title: String?
    var color: UIColor = .white
    
    init(location:MapLocation) {
        locationInfo = location
        coordinate = location.coordinates
    }

}
