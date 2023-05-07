//
//  MKCoordinateRegion+Extensions.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

//https://stackoverflow.com/questions/21034409/how-to-determine-the-correct-altitude-for-an-mkmapcamera-focusing-on-an-mkpolygo
extension MKCoordinateRegion {
    
    init(from coordinates: [CLLocationCoordinate2D], spanMultiplier: CLLocationDistance = 1.0) {
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for coordinate in coordinates {
            topLeftCoord.longitude = min(topLeftCoord.longitude, coordinate.longitude)
            topLeftCoord.latitude = max(topLeftCoord.latitude, coordinate.latitude)
            
            bottomRightCoord.longitude = max(bottomRightCoord.longitude, coordinate.longitude)
            bottomRightCoord.latitude = min(bottomRightCoord.latitude, coordinate.latitude)
        }
        
        let cent = CLLocationCoordinate2D.init(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)
        let span = MKCoordinateSpan.init(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * spanMultiplier, longitudeDelta: abs(bottomRightCoord.longitude - topLeftCoord.longitude) * spanMultiplier)
        
        self.init(center: cent, span: span)
    }
    
    var east: CLLocation {
        return CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta / 2)
    }
    var west: CLLocation {
        return CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta / 2)
    }
    var longitudinalMeters: CLLocationDistance {
        return east.distance(from: west)
    }
}
