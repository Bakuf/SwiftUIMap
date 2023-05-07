//
//  MapLock.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

public struct MapLock {
    public init(region: MKCoordinateRegion? = nil, minLevel: Int? = nil, maxLevel: Int? = nil) {
        self.region = region
        self.minLevel = minLevel
        self.maxLevel = maxLevel
    }
    
    var region: MKCoordinateRegion?
    var minLevel : Int?
    var maxLevel : Int?
    
    public static var none: MapLock { .init() }
}

extension MapLock {
    
    func apply(to map: MapView) {
        MapLock.unlock(map: map)
        
        if let region = region {
            map.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        }
        if let min = minLevel, let max = maxLevel {
            map.zoomLevel = max
            map.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: map.calculateCenterCoordinateDistance(for: min), maxCenterCoordinateDistance: map.calculateCenterCoordinateDistance(for: max))
        }else if let min = minLevel {
            map.zoomLevel = min
            map.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: map.calculateCenterCoordinateDistance(for: min))
        }else if let max = maxLevel {
            map.zoomLevel = max
            map.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: map.calculateCenterCoordinateDistance(for: max))
        }
    }
    
    static func unlock(map: MapView) {
        map.cameraBoundary = .none
        map.cameraZoomRange = .none
    }
    
}
