//
//  MapView+Utils.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

//MARK: Utils
extension MapView {
    func calculateZoomLevel() -> Int {
        let lvl = log2(360 * (Double(UIScreen.main.bounds.width/256) / self.region.span.longitudeDelta)) + 1
        if !lvl.isInfinite {
            return Int(lvl)
        }else{
            return 0
        }
    }
    
    func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        let lvl = zoomLevel == 0 ? 1 : zoomLevel
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(lvl)) * Double(UIScreen.main.bounds.width) / 256)
        setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animated)
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
