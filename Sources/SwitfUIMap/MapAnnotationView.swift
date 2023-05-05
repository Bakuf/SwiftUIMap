//
//  MapAnnotationView.swift
//  
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import SwiftUI
import MapKit
 
public protocol SwiftUIMapAnnotationView : View {
    var hostingControllerView : UIView { get }
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
    
    public override var annotation: MKAnnotation? {
        didSet {
            guard let ann = annotation as? MapAnnotation else {
                return
            }
            if let view = ann.locationInfo.view,
               lastIdentifier != ann.locationInfo.identifier {
                for subview in subviews {
                    subview.removeFromSuperview()
                }
                addSubview(view.hostingControllerView)
                lastIdentifier = ann.locationInfo.identifier
            }
        }
    }
    
}
