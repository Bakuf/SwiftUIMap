import SwiftUI

public struct SwitfUIMap : UIViewRepresentable {

    public init(coordinator: MapCoordinator = .init()) {
        self.coordinator = coordinator
    }
    
    public let coordinator: MapCoordinator

    public func makeUIView(context: Context) -> MapView {
        let mapView = MapView(coordinator: coordinator)
        return mapView
    }
    
    public func updateUIView(_ uiView: MapView, context: Context) {}
}
