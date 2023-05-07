//
//  MapView+Overlays.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

extension MapView {
    
    var overlayIds: [String] {
        overlays.compactMap({ $0 as? MapOverlay }).map({$0.id})
    }
    
    func update(overlays: [MapOverlay]) {
        let currentOverlays = overlayIds
        var overlayDictionary : [String:MapOverlay] = [:]
        overlays.forEach { overlay in
            overlayDictionary[overlay.id] = overlay
        }
        let diff = Array(overlayDictionary.keys).difference(from: currentOverlays)
        diff.forEach { id in
            if let overlay = overlayDictionary[id] as? MKOverlay {
                addOverlay(overlay, level: overlayDictionary[id]?.level ?? .aboveLabels)
            }else{
                removeOverlay(with: id)
            }
        }
    }
    
    func removeOverlay(with identifier: String) {
        overlays.compactMap({ $0 as? MapOverlay })
            .filter({ $0.id == identifier })
            .forEach { overlay in
                if let castOverlay = overlay as? MKOverlay {
                    removeOverlay(castOverlay)
                }
            }
    }
    
    func removeAllOverlays(of classType: AnyClass) {
        removeOverlays(overlays.filter({ $0.isKind(of: classType) }))
    }
    
    func removeAllAnnotations(of classType: AnyClass) {
        removeAnnotations(annotations.filter({ $0.isKind(of: classType) }))
    }
    
}
