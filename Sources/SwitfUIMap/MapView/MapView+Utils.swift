//
//  MapView+Utils.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

//MARK: Utils
extension MapView {
    func calculateZoomLevel(in region: MKCoordinateRegion? = nil) -> Int {
        let finalRegion = region ?? self.region
        let lvl = log2(360 * (Double(bounds.width/256) / finalRegion.span.longitudeDelta)) + 1
        if !lvl.isInfinite {
            return Int(lvl)
        }else{
            return 0
        }
    }
    
    func region(at coordinate: CLLocationCoordinate2D, zoomLevel: Int) -> MKCoordinateRegion {
        let lvl = zoomLevel == 0 ? 1 : zoomLevel
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(lvl)) * Double(UIScreen.main.bounds.width) / 256)
        return .init(center: coordinate, span: span)
    }
    
    func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        let region = region(at: coordinate, zoomLevel: zoomLevel)
        reportChangeIn(region: region)
        setRegion(region, animated: animated)
    }
    
    func calculateCenterCoordinateDistance(for zoomLevel: Int) -> CLLocationDistance {
        let zoomLevel = CGFloat(zoomLevel)
        let width = self.frame.size.width
        let span = MKCoordinateSpan(latitudeDelta: 0.0, longitudeDelta:
            CLLocationDegrees(360 * width / (pow(2, (zoomLevel - 1)) * 256)))
        let region = MKCoordinateRegion(center: self.region.center, span: span)
        
        let aspectRatio = Double(self.frame.size.height / self.frame.size.width)
        let radianCameraAperture: Double = 29.8 * .pi / 180
        let areaRadius = aspectRatio * region.longitudinalMeters / 2

        return areaRadius / tan(radianCameraAperture / 2)
    }
}
