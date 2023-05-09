//
//  SwiftUIMapAnnotationView.swift
//  
//
//  Created by Rodrigo Galvez on 09/05/23.
//

import SwiftUI

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
