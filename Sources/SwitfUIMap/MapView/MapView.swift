//
//  MapView.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import MapKit
import Combine

public class MapView: MKMapView {
    
    weak var coordinator: MapCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var singleTapRecognizer : UITapGestureRecognizer?
    var ignoreSetZoomLevel = false
    
    init(coordinator: MapCoordinator) {
        super.init(frame: .zero)
        subscribe(to: coordinator)
        self.coordinator = coordinator
        coordinator.mapView = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tileColor : UIColor = .clear {
        didSet {
            removeAllOverlays(of: MapColorTileOverlay.classForCoder())
            if tileColor != .clear {
                let tiles = MapColorTileOverlay(color: tileColor)
                tiles.canReplaceMapContent = true
                addOverlay(tiles, level: .aboveLabels)
            }
        }
    }
    
    var zoomLevel: Int {
        get {
            return calculateZoomLevel()
        }
        set (newZoomLevel){
            if !ignoreSetZoomLevel {
                setCenterCoordinate(coordinate:self.centerCoordinate, zoomLevel: newZoomLevel, animated: false)
            }
            ignoreSetZoomLevel = false
        }
    }
    
    var reportTapLocation = false {
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
    
    var mapLock : MapLock? {
        didSet {
            if let lock = mapLock {
                lock.apply(to: self)
            }else{
                MapLock.unlock(map: self)
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
        
        coordinator.$lock.sink { [weak self] lock in
            self?.mapLock = lock
        }.store(in: &cancellables)
    }
}

//MARK: Touch Gestures
extension MapView : UIGestureRecognizerDelegate {
    @objc private func mapTapped(recognizer: UIGestureRecognizer){
        let tapPoint = recognizer.location(in: self)
        let tapLocation = self.convert(tapPoint, toCoordinateFrom: self)
        
        
        
        let locInfo = MapLocation(identifier: UUID().uuidString,
                                  coordinates: tapLocation)
        
        coordinator?.tapLocation = locInfo
    }
}
