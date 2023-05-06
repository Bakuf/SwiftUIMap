//
//  MapAnnotationView.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import SwiftUI
import MapKit
import Combine

public enum AnnotationAnchor {
    case topLeft
    case top
    case topRight
    case left
    case center
    case right
    case bottomLeft
    case bottom
    case bottomRight
}

extension AnnotationAnchor {
    func getAnchorPoint(from size: CGSize) -> CGPoint {
        switch self {
        case .topLeft:
            return .init(x: size.width * 0.5, y: size.height * 0.5)
        case .top:
            return .init(x: 0, y: size.height * 0.5)
        case .topRight:
            return .init(x: -(size.width * 0.5), y: size.height * 0.5)
        case .left:
            return .init(x: size.width * 0.5, y: 0)
        case .center:
            return .init(x: 0, y: 0)
        case .right:
            return .init(x: -(size.width * 0.5), y: 0)
        case .bottomLeft:
            return .init(x: size.width * 0.5, y: -(size.height * 0.5))
        case .bottom:
            return .init(x: 0, y: -(size.height * 0.5))
        case .bottomRight:
            return .init(x: -(size.width * 0.5), y: -(size.height * 0.5))
        }
    }
}

public class AnnotationCoordinator : ObservableObject {
    public init(isSelected: Bool = false, frame: CGRect = .init(x: 0, y: 0, width: 100, height: 100), anchorPoint: AnnotationAnchor = .center) {
        self.frame = frame
        self.isSelected = isSelected
        self.anchorPoint = anchorPoint
    }

    @Published public var frame: CGRect
    @Published public var isSelected: Bool
    @Published public var anchorPoint: AnnotationAnchor
}

public extension AnnotationCoordinator {
    func animateChange(of frame: CGRect, duration: CGFloat = 1.0, delay: CGFloat = 0.0, type: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: delay, options: type) { [weak self] in
            self?.frame = frame
        }
    }
}
 
public protocol SwiftUIMapAnnotationView : View {
    var hostingControllerView : UIView { get }
    var annCoordinator: AnnotationCoordinator { get }
}

extension SwiftUIMapAnnotationView {
    public var hostingControllerView: UIView { convert(view: self) }
    public func convert<Content: View>(view: Content) -> UIView {
        let viewCtrl = UIHostingController(rootView: view)
        return viewCtrl.view
    }
}

public class MapAnnotationView : MKAnnotationView {
    
    private var lastIdentifier : String = ""
    private var tapRecognizer : UITapGestureRecognizer?
    
    private var longPressTimer : Timer?
    private var currentCenter = CGPoint.zero
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
            }
        }
    }
    
    func change(frame rect: CGRect) {
        frame = rect
        guard let annView = annView else { return }
        centerOffset = annView.annCoordinator.anchorPoint.getAnchorPoint(from: rect.size)
    }
    
}
