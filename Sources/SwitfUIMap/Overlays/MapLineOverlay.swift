//
//  MapLineOverlay.swift
//  
//
//  Created by Rodrigo Galvez on 06/05/23.
//

import MapKit

public class MapLineOverlay: MKPolyline, MapOverlay {
    public convenience init(id: String = UUID().uuidString,
                            coordinates: [CLLocationCoordinate2D],
                            lineWidth: CGFloat = 3,
                            alpha: CGFloat = 1.0,
                            color: UIColor = .red,
                            dashLine: Bool = false,
                            level: MKOverlayLevel = .aboveRoads) {
        self.init(coordinates: coordinates, count: coordinates.count)
        self.id = id
        self.lineWidth = lineWidth
        self.alpha = alpha
        self.color = color
        self.dashLine = dashLine
        self.level = level
    }
    
    public var id: String = UUID().uuidString
    public var type: MapOverlayType { .line }
    public var level: MKOverlayLevel = .aboveRoads

    public var lineWidth: CGFloat = 3
    public var alpha: CGFloat = 1.0
    public var color: UIColor = .red
    public var dashLine : Bool = false
    
}

extension MapLineOverlay: MapOverlayRenderProvider {
    var renderer: MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: self)
        renderer.strokeColor = color
        renderer.lineWidth = lineWidth
        renderer.lineDashPattern = dashLine ? [4,10] : nil
        renderer.alpha = alpha
        return renderer
    }
}
