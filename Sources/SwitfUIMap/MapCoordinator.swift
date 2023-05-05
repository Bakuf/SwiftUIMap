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
}
    
