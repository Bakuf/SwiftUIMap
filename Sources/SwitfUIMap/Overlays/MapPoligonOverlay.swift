//
//  File.swift
//  
//
//  Created by Rodrigo Galvez on 06/05/23.
//

import MapKit

public class MapPoligonOverlay: MKPolygon, MapOverlay {
    public convenience init(id: String = UUID().uuidString,
                            coordinates: [CLLocationCoordinate2D],
                            lineWidth: CGFloat = 3,
                            alpha: CGFloat = 1.0,
                            color: UIColor = .red,
                            dashLine: Bool = false,
                            level: MKOverlayLevel = .aboveRoads) {
        self.init(coordinates: coordinates, count: coordinates.count)
        self.id = id
        self.alpha = alpha
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.level = level
    }
    
    public var id: String = UUID().uuidString
    public var type: MapOverlayType { .polygon }
    public var level: MKOverlayLevel = .aboveLabels

    public var alpha: CGFloat = 0.5
    public var fillColor: UIColor = .blue
    public var strokeColor: UIColor?
    public var lineWidth: CGFloat = 3
    
}

extension MapPoligonOverlay: MapOverlayRenderProvider {
    var renderer: MKOverlayRenderer {
        let renderer = MKPolygonRenderer(polygon: self)
        renderer.fillColor = fillColor
        renderer.strokeColor = strokeColor
        renderer.lineWidth = lineWidth
        renderer.alpha = alpha
        return renderer
    }
}
