//
//  MapView+Annotations.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

extension MapView {
    
    var annotationIds: [String] {
        annotations.compactMap({ $0 as? MapAnnotation }).map({$0.locationInfo.identifier})
    }
    
    func update(locations: [MapLocation]) {
        let currentAnn = annotationIds
        var locDictionary : [String:MapLocation] = [:]
        locations.forEach { location in
            locDictionary[location.identifier] = location
        }
        let diff = Array(locDictionary.keys).difference(from: currentAnn)
        diff.forEach { id in
            if let loc = locDictionary[id] {
                addAnnotation(MapAnnotation(location: loc))
            }else{
                removeAnnotation(with: id)
            }
        }
    }
    
    func removeAnnotation(with identifier: String) {
        annotations.compactMap({ $0 as? MapAnnotation })
            .filter({ $0.locationInfo.identifier == identifier })
            .forEach { ann in
                removeAnnotation(ann)
            }
    }
}
