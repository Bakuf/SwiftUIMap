//
//  MapCircleOverlay.swift
//  
//
//  Created by Rodrigo Galvez on 06/05/23.
//

import MapKit

public class MapCircleOverlay: MKCircle, MapOverlay {
    public convenience init(id: String = UUID().uuidString,
                            radius: CGFloat = 1000,
                            center: CLLocationCoordinate2D,
                            alpha: CGFloat = 0.5,
                            fillColor: UIColor = .blue,
                            strokeColor: UIColor? = nil,
                            lineWidth: CGFloat = 3,
                            level: MKOverlayLevel = .aboveRoads) {
        self.init(center: center, radius: radius)
        self.id = id
        self.alpha = alpha
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.level = level
    }
    
    public var id: String = UUID().uuidString
    public var type: MapOverlayType { .circle }
    public var level: MKOverlayLevel = .aboveLabels

    public var alpha: CGFloat = 0.5
    public var fillColor: UIColor = .blue
    public var strokeColor: UIColor?
    public var lineWidth: CGFloat = 3
}

extension MapCircleOverlay: MapOverlayRenderProvider {
    var renderer: MKOverlayRenderer {
        let renderer = MKCircleRenderer(circle: self)
        renderer.fillColor = fillColor
        renderer.strokeColor = strokeColor
        renderer.lineWidth = lineWidth
        renderer.alpha = alpha
        return renderer
    }
}

