//
//  MapCoordinator.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//


import SwiftUI
import MapKit

final public class MapCoordinator: ObservableObject {
    public init(mapType: MKMapType = .standard, zoomLevel: Int = 0, locations : [MapLocation] = [], overlays: [MapOverlay] = []) {
        self.mapType = mapType
        self.zoomLevel = zoomLevel
        self.locations = locations
        self.overlays = overlays
    }
    
    @Published public var mapType: MKMapType
    @Published public var zoomLevel : Int
    
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
    
    //Will center the map on the given coordinate, zoomLevel can be between 1 and 20, the bigger the number the closer to the ground
    func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool = true) {
        mapView?.setCenterCoordinate(coordinate: coordinate, zoomLevel: zoomLevel, animated: animated)
    }
    
    ///Will lock the map to the given region
    func lock(region: MKCoordinateRegion, zoomLevel: Int, zoomRange: Int = 3) {
        var minZoom = min(Int(zoomLevel) + (zoomRange / 2), 20)
        var maxZoom = max(1, Int(zoomLevel) - (zoomRange / 2))
        if minZoom == 20 { maxZoom = minZoom - zoomRange }
        if maxZoom == 1 { minZoom = maxZoom + zoomRange }
        lock = .init(region: region, minLevel: minZoom, maxLevel: maxZoom)
    }
    
    ///Will lock the map at the given coordinates
    func lockRegion(at centerCoord: CLLocationCoordinate2D, zoomLevel: Int, zoomRange: Int = 3) {
        guard let mapView = mapView else { return }
        lock(region: mapView.region(at: centerCoord, zoomLevel: zoomLevel), zoomLevel: zoomLevel, zoomRange: zoomRange)
    }
    
    func registerBuilder(for clusterId: String, builder: @escaping ClusterBuilder) {
        mapView?.clusterRegistry[clusterId] = builder
    }
    
}
