//
//  MapOverlay.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import MapKit

public enum MapOverlayType {
    case colorTile
    case tileService
    case imageOverlay
    case line
    case circle
    case polygon
}

public protocol MapOverlay {
    var id: String { get }
    var type : MapOverlayType { get }
    var level : MKOverlayLevel { get }
}

protocol MapOverlayRenderProvider {
    var renderer : MKOverlayRenderer { get }
}
