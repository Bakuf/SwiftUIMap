//
//  MapView+MKMapViewDelegate.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

extension MapView : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.ignoreSetZoomLevel = true
            self.coordinator?.zoomLevel = CGFloat(self.calculateZoomLevel())
            self.coordinator?.visibleRegion = mapView.region
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let ann = annotation as? MapAnnotation else {
            return dequeueReusableAnnotationView(withIdentifier: "default")
        }
        var annView = dequeueReusableAnnotationView(withIdentifier: "MapAnnotation")
        if annView == nil {
            annView = MapAnnotationView(annotation: ann, reuseIdentifier: "MapAnnotation")
        }else{
            annView?.annotation = ann
        }
        return annView
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let renderProvider = overlay as? MapOverlayRenderProvider else { return MKOverlayRenderer(overlay: overlay) }
        return renderProvider.renderer
    }
}
