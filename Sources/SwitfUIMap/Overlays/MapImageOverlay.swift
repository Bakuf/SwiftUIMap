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
    
    override init(overlay: MKOverlay) {
        if let imageOverlay = overlay as? MapImageOverlay {
            self.overlayImage = imageOverlay.image
        }else{
            self.overlayImage = nil
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
        context.translateBy(x: 0.0, y: -rect.size.height)
        context.draw(imageReference, in: rect)
    }
}

public class MapImageOverlay: NSObject, MKOverlay, MapOverlay {
    public var id : String
    public var type: MapOverlayType { .imageOverlay }
    
    public let coordinate: CLLocationCoordinate2D
    public let boundingMapRect: MKMapRect
    public let image: UIImage
    public let level : MKOverlayLevel
    
    public init(identifier : String = UUID().uuidString, location: MapLocation, image: UIImage, level: MKOverlayLevel = .aboveLabels) {
        boundingMapRect = location.boundingMapRect ?? .init(origin: .init(location.coordinates), size: .init(width: 2000, height: 2000))
        coordinate = location.coordinates
        self.id = identifier
        self.image = image
        self.level = level
    }
}

extension MapImageOverlay: MapOverlayRenderProvider {
    var renderer : MKOverlayRenderer { ImageOverlayRenderer(overlay: self) }
}
