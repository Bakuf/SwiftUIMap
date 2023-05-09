//
//  MapLocation.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import Foundation
import MapKit

public struct MapLocation : Hashable {
    
    public static func == (lhs: MapLocation, rhs: MapLocation) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public init(identifier: String = UUID().uuidString, name : String? = nil, placeMark: MKPlacemark? = nil, coordinates: CLLocationCoordinate2D, accuracy: CLAccuracyAuthorization = .fullAccuracy, radius: Double? = nil, boundingMapRect: MKMapRect? = nil, clusterId: String? = nil , view: (any SwiftUIMapAnnotationView)? = nil) {
        self.identifier = identifier
        self.name = name
        self.placeMark = placeMark
        self.coordinates = coordinates
        self.accuracy = accuracy
        self.radius = radius
        self.clusterId = clusterId
        self.view = view
        self.boundingMapRect = boundingMapRect
    }
    
    ///Required to uniquely identify this location, this will be set in the annotation too
    public var identifier : String
    ///Name of location
    public var name : String?
    ///Placemark info for this location
    public var placeMark : MKPlacemark?
    ///The map coordinates
    public var coordinates : CLLocationCoordinate2D
    ///The Accurary of the coordinates, by defaul reducedAccuracy will show circle overlay
    public var accuracy : CLAccuracyAuthorization
    ///Radius in Meters for use in approx location
    public var radius : Double?
    ///Used for overlays
    public var boundingMapRect: MKMapRect?
    ///Used for clustering
    public var clusterId: String?
    
    public var view: (any SwiftUIMapAnnotationView)?
    
    ///If placeMark is not empty this method will provide the best available name for the location at the desired zoomLevel (<16 = name,thoroughfare,16-14 = locality,13-11 = subAdmin- admin, 10> = country+)
    public func getBestLocationName(zoomLevel:Int? = nil) -> String {
        var possibleNames : [String?] = [placeMark?.name,
                                         placeMark?.thoroughfare,
                                         placeMark?.locality,
                                         placeMark?.subLocality,
                                         placeMark?.subAdministrativeArea,
                                         placeMark?.administrativeArea,
                                         placeMark?.country,
                                         placeMark?.inlandWater,
                                         placeMark?.ocean]
        if let zoomLevel = zoomLevel {
            possibleNames = []
            let lowZoom = [placeMark?.name, placeMark?.thoroughfare]
            let midZoom = [placeMark?.locality, placeMark?.subLocality]
            let highZoom = [placeMark?.subAdministrativeArea, placeMark?.administrativeArea]
            if zoomLevel > 16 {
                possibleNames.append(contentsOf: lowZoom)
            }
            if zoomLevel > 13   {
                possibleNames.append(contentsOf: midZoom)
            }
            if zoomLevel > 10 {
                possibleNames.append(contentsOf: highZoom)
            }
            possibleNames.append(contentsOf: [placeMark?.country,placeMark?.inlandWater,placeMark?.ocean])
        }
        let filteredNames = possibleNames.filter({$0 != nil})
        //print("possibleName : \(filteredNames)")
        return filteredNames.count > 0 ? filteredNames[0]! : ""
    }
    
    public func openInAppleMaps(){
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
    
    public func with(clusterId: String? = nil, view: any SwiftUIMapAnnotationView) -> MapLocation {
        var newSelf = self
        newSelf.clusterId = clusterId
        newSelf.view = view
        return newSelf
    }
    
}

extension MapLocation {
    public static var none : MapLocation {
        .init(identifier: "none", coordinates: .init(latitude: -1222.0, longitude: -1222.0))
    }
}
