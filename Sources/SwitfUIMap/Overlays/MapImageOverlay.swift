//
//  ImageOverlay.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import Foundation
import MapKit

class ImageOverlayRenderer: MKOverlayRenderer {
    let overlayImage: UIImage?
    let anchor: MapAnchor?
    
    override init(overlay: MKOverlay) {
        if let imageOverlay = overlay as? MapImageOverlay {
            self.overlayImage = imageOverlay.image
            self.anchor = imageOverlay.anchor
        }else{
            self.overlayImage = nil
            self.anchor = nil
        }
        super.init(overlay: overlay)
    }
    
    override func draw(
        _ mapRect: MKMapRect,
        zoomScale: MKZoomScale,
        in context: CGContext
    ) {
        guard let imageReference = overlayImage?.cgImage else { return }
        
        let rect = self.rect(for: overlay.boundingMapRect)
        context.scaleBy(x: 1.0, y: -1.0)
        if let anchor = anchor {
            let point = anchor.getImagePoint(from: rect.size)
            context.translateBy(x: point.x, y: point.y)
        }else{
            context.translateBy(x: -((rect.size.width / 2)), y: -(rect.size.height / 2))
        }
        context.draw(imageReference, in: rect)
    }
}

public class MapImageOverlay: NSObject, MKOverlay, MapOverlay {
    public var id : String
    public var type: MapOverlayType { .imageOverlay }
    
    public let coordinate: CLLocationCoordinate2D
    public let boundingMapRect: MKMapRect
    public let image: UIImage
    public let anchor: MapAnchor
    public let level : MKOverlayLevel
    
    public init(identifier : String = UUID().uuidString, location: MapLocation, image: UIImage, scale: CGFloat = 100, anchor: MapAnchor = .center, level: MKOverlayLevel = .aboveLabels) {
        boundingMapRect = location.boundingMapRect ?? .init(origin: .init(location.coordinates),
                                                            size: .init(width: image.size.width * scale, height: image.size.height * scale))
        coordinate = location.coordinates
        self.id = identifier
        self.image = image
        self.anchor = anchor
        self.level = level
    }
}

extension MapImageOverlay: MapOverlayRenderProvider {
    var renderer : MKOverlayRenderer { ImageOverlayRenderer(overlay: self) }
}
