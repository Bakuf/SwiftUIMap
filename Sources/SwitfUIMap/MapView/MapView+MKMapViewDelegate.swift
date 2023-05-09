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
            self?.reportChangeIn(region: mapView.region)
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cluster = annotation as? MKClusterAnnotation { return annotationView(for: cluster) }
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

extension MapView {
    
    func annotationView(for cluster: MKClusterAnnotation) -> MKAnnotationView? {
        guard let firstMember = cluster.memberAnnotations.first as? MapAnnotation,
              let clusterId = firstMember.locationInfo.clusterId,
              let clusterBuilder = clusterRegistry[clusterId] else { return nil }
        var clusterView = dequeueReusableAnnotationView(withIdentifier: clusterId)
        
        if clusterView == nil {
            clusterView = MapClusterView(annotation: cluster, reuseIdentifier: clusterId)
        }
        
        guard let clusterView = clusterView as? MapClusterView else {
            return MKAnnotationView(annotation: cluster, reuseIdentifier: clusterId)
        }
        clusterView.annotation = cluster
        clusterView.annView = clusterBuilder()
        return clusterView
    }
    
}
