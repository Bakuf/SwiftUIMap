//
//  MapCoordinator.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//


import SwiftUI
import MapKit

final public class MapCoordinator: ObservableObject {
    public init(mapType: MKMapType = .standard, zoomLevel: CGFloat = 0, locations : [MapLocation] = [], overlays: [MapOverlay] = []) {
        self.mapType = mapType
        self.zoomLevel = zoomLevel
        self.locations = locations
        self.overlays = overlays
    }
    
    @Published public var mapType: MKMapType
    @Published public var zoomLevel : CGFloat
    
    @Published public var locations : [MapLocation]
    @Published public var overlays : [MapOverlay]
    
    @Published public var reportTapLocation: Bool = true
    @Published public var tapLocation : MapLocation = .none
    
    @Published public var tileColor : UIColor = .clear
    
    @Published public var visibleRegion: MKCoordinateRegion = .init()
    
    @Published public var lock: MapLock = .none
    
    weak var mapView: MapView?
}
 
public extension MapCoordinator {
    
    func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool = true) {
        mapView?.setCenterCoordinate(coordinate: coordinate, zoomLevel: zoomLevel, animated: animated)
    }
    
    func lockCurrentRegion(zoomRange: Int = 3) {
        var region = visibleRegion
        if let mapView = mapView {
            region = mapView.region
        }
        var minZoom = min(Int(zoomLevel) + (zoomRange / 2), 20)
        var maxZoom = max(1, Int(zoomLevel) - (zoomRange / 2))
        if minZoom == 20 { maxZoom = minZoom - zoomRange }
        if maxZoom == 1 { minZoom = maxZoom + zoomRange }
        lock = .init(region: region, minLevel: minZoom, maxLevel: maxZoom)
    }
    
}
