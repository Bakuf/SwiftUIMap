//
//  MapAnnotationView.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import SwiftUI
import MapKit
import Combine

public class MapAnnotationView : MKAnnotationView {
    
    private var lastIdentifier : String = ""
    private var cancellables = Set<AnyCancellable>()
    
    private var mapAnn : MapAnnotation? { annotation as? MapAnnotation }
    private var annView : (any SwiftUIMapAnnotationView)? {
        if let ann = mapAnn, let annView = ann.locationInfo.view { return annView }
        return nil
    }
    
    public override var annotation: MKAnnotation? {
        didSet {
            guard let mapAnn = mapAnn else { return }
            if let annView = annView,
               lastIdentifier != mapAnn.locationInfo.identifier {
                for subview in subviews {
                    subview.removeFromSuperview()
                }
                let view = annView.hostingControllerView
                view.backgroundColor = .clear
                addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                    view.topAnchor.constraint(equalTo: self.topAnchor),
                    view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
                lastIdentifier = mapAnn.locationInfo.identifier
                
                cancellables.forEach { cancellable in
                    cancellable.cancel()
                }
                cancellables = .init()
                
                annView.annCoordinator.$frame
                    .sink { [weak self] rect in
                        self?.change(frame: rect)
                    }.store(in: &cancellables)
                
                clusteringIdentifier = mapAnn.locationInfo.clusterId
            }
        }
    }
    
    func change(frame rect: CGRect) {
        frame = rect
        guard let annView = annView else { return }
        centerOffset = annView.annCoordinator.anchorPoint.getAnnotationPoint(from: rect.size)
    }
    
}
