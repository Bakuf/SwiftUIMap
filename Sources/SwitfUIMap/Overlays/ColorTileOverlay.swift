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
        if let colorOverlay = overlay as? ColorTileOverlay {
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

class ColorTileOverlay : MKTileOverlay, MapOverlay {
    var id: String { UUID().uuidString }
    var type: MapOverlayType { .colorTile }
    let color: UIColor
    
    internal init(color: UIColor) {
        self.color = color
        super.init(urlTemplate: nil)
    }
    
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}
