//
//  AnnotationCoordinator.swift
//  
//
//  Created by Rodrigo Galvez on 09/05/23.
//

import SwiftUI

public class AnnotationCoordinator : ObservableObject {
    public init(isSelected: Bool = false, frame: CGRect = .init(x: 0, y: 0, width: 100, height: 100), anchorPoint: MapAnchor = .center) {
        self.frame = frame
        self.isSelected = isSelected
        self.anchorPoint = anchorPoint
    }

    @Published public var frame: CGRect
    @Published public var isSelected: Bool
    @Published public var anchorPoint: MapAnchor
}

public extension AnnotationCoordinator {
    func animateChange(of frame: CGRect, duration: CGFloat = 1.0, delay: CGFloat = 0.0, type: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: delay, options: type) { [weak self] in
            self?.frame = frame
        }
    }
}
