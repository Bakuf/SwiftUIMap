//
//  ContentView.swift
//  SwiftUIMap Example
//
//  Created by Rodrigo Galvez on 04/05/23.
//

import SwiftUI
import MapKit
import SwitfUIMap

struct ContentView: View {
    
    @StateObject var mapCoordinator: MapCoordinator = .init()

    var body: some View {
        VStack {
            HStack {
                Button("Clear Annotations") {
                    mapCoordinator.locations = []
                }
                Button("Add Overlay") {
                    if let image = UIImage(named: "usaMap") {
                        mapCoordinator.overlays.append(
                            ImageOverlay(location: .init(coordinates: mapCoordinator.tapLocation.coordinates), image: image)
                        )
                    }
                }
                Button("Clear Overlay") {
                    mapCoordinator.overlays = []
                }
            }
            HStack {
                Text("Map type")
                Picker("Map type", selection: $mapCoordinator.mapType) {
                    Text("Standard")
                        .tag(MKMapType.standard)
                    Text("Satellite")
                        .tag(MKMapType.satellite)
                }
                .pickerStyle(.segmented)
            }
            HStack {
                Text("Color Tile")
                Picker("Color Tile", selection: $mapCoordinator.tileColor) {
                    Text("clear")
                        .tag(UIColor.clear)
                    Text("blue")
                        .tag(UIColor.blue)
                }
                .pickerStyle(.segmented)
            }
            HStack {
                Text("zoom: \(Int(mapCoordinator.zoomLevel))")
                Slider(value: $mapCoordinator.zoomLevel, in: 0...20)
            }
            Text("tap coords : \(mapCoordinator.tapLocation.coordinates.longitude) - \(mapCoordinator.tapLocation.coordinates.latitude)")
            ZStack {
                SwitfUIMap(coordinator: mapCoordinator)
            }
            .onChange(of: mapCoordinator.tapLocation) { newValue in
                mapCoordinator.locations.append(
                    newValue.with(TestAnnotationView())
                )
            }
        }
        .padding()
    }
}

struct TestAnnotationView : SwiftUIMapAnnotationView {
    var body: some View {
        ZStack{
            Circle()
                .fill(.blue)
                .opacity(0.5)
        }
        .frame(width: 100, height: 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TestAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        TestAnnotationView()
    }
}
