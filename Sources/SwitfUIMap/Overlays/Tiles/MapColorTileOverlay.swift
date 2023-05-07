//
//  ColorTileOverlay.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import MapKit

class ColorOverlayRenderer: MKOverlayRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let drawRect = self.rect(for: mapRect)
        if let colorOverlay = overlay as? MapColorTileOverlay {
            let rgba = colorOverlay.color.rgba
            context.setFillColor(red: rgba.red,
                                 green: rgba.green,
                                 blue: rgba.blue,
                                 alpha: rgba.alpha)
        }else{
            context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        context.fill(drawRect)
    }
}

class MapColorTileOverlay : MKTileOverlay, MapOverlay {
    var id: String { UUID().uuidString }
    var type: MapOverlayType { .colorTile }
    let color: UIColor
    let level : MKOverlayLevel = .aboveLabels
    
    internal init(color: UIColor) {
        self.color = color
        super.init(urlTemplate: nil)
    }
    
}

extension MapColorTileOverlay: MapOverlayRenderProvider {
    var renderer : MKOverlayRenderer { ColorOverlayRenderer(overlay: self) }
}
