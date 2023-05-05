//
//  MapOveray.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import MapKit

public enum MapOverlayType {
    case colorTile
    case imageOverlay
}

public protocol MapOverlay {
    var id: String { get }
    var type : MapOverlayType { get }
}
