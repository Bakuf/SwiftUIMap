//
//  MapView.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import MapKit
import Combine

public class MapView: MKMapView {
    
    private weak var coordinator: MapCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var singleTapRecognizer : UITapGestureRecognizer?
    
    init(coordinator: MapCoordinator) {
        super.init(frame: .zero)
        subscribe(to: coordinator)
        self.coordinator = coordinator
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var tileColor : UIColor = .clear {
        didSet {
            removeAllOverlays(of: ColorTileOverlay.classForCoder())
            if tileColor != .clear {
                let tiles = ColorTileOverlay(color: tileColor)
                tiles.canReplaceMapContent = true
                addOverlay(tiles, level: .aboveLabels)
            }
        }
    }
    
    public var zoomLevel: Int {
        get {
            return calculateZoomLevel()
        }
        set (newZoomLevel){
            setCenterCoordinate(coordinate:self.centerCoordinate, zoomLevel: newZoomLevel, animated: false)
        }
    }
    
    public var reportTapLocation = false {
        didSet {
            if reportTapLocation {
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(recognizer:)))
                tapRecognizer.numberOfTapsRequired = 1;
                self.addGestureRecognizer(tapRecognizer)
                singleTapRecognizer = tapRecognizer
            }else{
                if let singleTap = singleTapRecognizer {
                    self.removeGestureRecognizer(singleTap)
                }
            }
        }
    }
}

extension MapView {
    func subscribe(to coordinator: MapCoordinator) {
        coordinator.$mapType
            .assign(to: \.mapType, on: self)
            .store(in: &cancellables)
        coordinator.$zoomLevel
            .map({ Int($0) })
            .assign(to: \.zoomLevel, on: self)
            .store(in: &cancellables)
        coordinator.$reportTapLocation
            .assign(to: \.reportTapLocation, on: self)
            .store(in: &cancellables)
        coordinator.$locations.sink { [weak self] locations in
            self?.update(locations: locations)
        }.store(in: &cancellables)
        coordinator.$tileColor.assign(to: \.tileColor, on: self).store(in: &cancellables)
        coordinator.$overlays.sink { [weak self] overlays in
            self?.update(overlays: overlays)
        }.store(in: &cancellables)
    }
}

extension MapView {
    private func calculateZoomLevel() -> Int {
        let lvl = log2(360 * (Double(UIScreen.main.bounds.width/256) / self.region.span.longitudeDelta)) + 1
        if !lvl.isInfinite {
            return Int(lvl)
        }else{
            return 0
        }
    }
    
    private func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        let lvl = zoomLevel == 0 ? 1 : zoomLevel
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(lvl)) * Double(UIScreen.main.bounds.width) / 256)
        setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animated)
    }
}

extension MapView {
    
    fileprivate func update(locations: [MapLocation]) {
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
    
    fileprivate func update(overlays: [MapOverlay]) {
        let currentOverlays = overlayIds
        var overlayDictionary : [String:MapOverlay] = [:]
        overlays.forEach { overlay in
            overlayDictionary[overlay.id] = overlay
        }
        let diff = Array(overlayDictionary.keys).difference(from: currentOverlays)
        diff.forEach { id in
            if let overlay = overlayDictionary[id] as? MKOverlay {
                addOverlay(overlay, level: .aboveLabels)
            }else{
                removeOverlay(with: id)
            }
        }
    }

}

extension MapView {
    public var annotationIds: [String] {
        annotations.compactMap({ $0 as? MapAnnotation }).map({$0.locationInfo.identifier})
    }
    
    public var overlayIds: [String] {
        overlays.compactMap({ $0 as? MapOverlay }).map({$0.id})
    }
    
    public func removeAnnotation(with identifier: String) {
        annotations.compactMap({ $0 as? MapAnnotation })
            .filter({ $0.locationInfo.identifier == identifier })
            .forEach { ann in
                removeAnnotation(ann)
            }
    }
    
    public func removeOverlay(with identifier: String) {
        overlays.compactMap({ $0 as? MapOverlay })
            .filter({ $0.id == identifier })
            .forEach { overlay in
                if let castOverlay = overlay as? MKOverlay {
                    removeOverlay(castOverlay)
                }
            }
    }
    
    public func removeAllOverlays(of classType: AnyClass) {
        removeOverlays(overlays.filter({ $0.isKind(of: classType) }))
    }
    
    public func removeAllAnnotations(of classType: AnyClass) {
        removeAnnotations(annotations.filter({ $0.isKind(of: classType) }))
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension MapView : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
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
        guard let mapOverlay = overlay as? MapOverlay else { return MKOverlayRenderer(overlay: overlay) }
        switch mapOverlay.type {
        case .colorTile:
            return ColorOverlayRenderer(overlay: overlay)
        case .imageOverlay:
            return ImageOverlayRenderer(overlay: overlay)
        }
    }
}

extension MapView {
    @objc private func mapTapped(recognizer: UIGestureRecognizer){
        let tapPoint = recognizer.location(in: self)
        let tapLocation = self.convert(tapPoint, toCoordinateFrom: self)
        
        let locInfo = MapLocation(identifier: UUID().uuidString,
                                  coordinates: tapLocation)
        
        coordinator?.tapLocation = locInfo
    }
}
