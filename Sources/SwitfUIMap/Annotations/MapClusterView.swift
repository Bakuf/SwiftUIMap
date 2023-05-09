//
//  File.swift
//  
//
//  Created by Rodrigo Galvez on 09/05/23.
//

import Foundation

import SwiftUI
import MapKit
import Combine

public class MapClusterView : MKAnnotationView {
    
    private var cancellables = Set<AnyCancellable>()
    
    var annView : (any SwiftUIMapAnnotationView)? {
        didSet {
            guard let annView = annView else { return }
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
            
            cancellables.forEach { cancellable in
                cancellable.cancel()
            }
            cancellables = .init()
            
            annView.annCoordinator.$frame
                .sink { [weak self] rect in
                    self?.change(frame: rect)
                }.store(in: &cancellables)
        }
    }
    
    func change(frame rect: CGRect) {
        frame = rect
        guard let annView = annView else { return }
        centerOffset = annView.annCoordinator.anchorPoint.getAnnotationPoint(from: rect.size)
    }
    
}
