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
    
    @State var locked: Bool = false
    @State var text = ""
    
    let applePark : CLLocationCoordinate2D = .init(latitude: 37.334600, longitude: -122.009200)

    var body: some View {
        VStack {
            Text("SwiftUIMap")
                .font(.largeTitle)
                .bold()
            Text(text)
                .font(.body)
                .bold()
            HStack {
                Text("zoom: \(mapCoordinator.zoomLevel)")
                Slider(value: .convert(from: $mapCoordinator.zoomLevel) , in: 0...20, step: 1)
            }
            if mapCoordinator.tapLocation != .none {
                Text("tap coords : \(mapCoordinator.tapLocation.coordinates.latitude) - \(mapCoordinator.tapLocation.coordinates.longitude)")
            }
            ZStack {
                SwitfUIMap(coordinator: mapCoordinator)
                    .onAppear{
                        mapCoordinator.registerBuilder(for: "clusteredAnn", builder: { TestClusterView() })
                        mapCoordinator.setCenterCoordinate(coordinate: applePark, zoomLevel: 16, animated: true)
                    }
                VStack {
                    Text("map center \n \(mapCoordinator.visibleRegion.center.latitude) - \(mapCoordinator.visibleRegion.center.longitude)")
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
                        .padding()
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: mapCoordinator.mapType == .standard ? "map.fill" : "globe.americas.fill")
                            .onTapGesture {
                                if mapCoordinator.mapType == .standard {
                                    mapCoordinator.mapType = .hybridFlyover
                                    text = "Set Hybrid Flyover map type"
                                } else {
                                    mapCoordinator.mapType = .standard
                                    text = "Set Standard map type"
                                }
                            }
                            .padding([.leading, .top, .bottom])
                        Image(systemName: "apple.logo")
                            .onTapGesture {
                                mapCoordinator.setCenterCoordinate(coordinate: applePark, zoomLevel: 16, animated: true)
                                text = "Centered on Apple Park"
                            }
                        Image(systemName: locked ? "lock.fill" : "lock.open.fill")
                            .onTapGesture {
                                if locked {
                                    mapCoordinator.lock = .none
                                    text = "Region unlocked"
                                }else{
                                    mapCoordinator.lock(region: mapCoordinator.visibleRegion, zoomLevel: mapCoordinator.zoomLevel)
                                    text = "Region locked"
                                }
                                locked.toggle()
                            }
                        Image(systemName: mapCoordinator.tileColor == .clear ? "paintbrush" : "paintbrush.fill")
                            .onTapGesture {
                                if mapCoordinator.tileColor == .clear {
                                    mapCoordinator.tileColor = .blue
                                    text = "Set Color Tileset"
                                } else {
                                    mapCoordinator.tileColor = .clear
                                    text = "Back to Apple Tileset"
                                }
                            }
                        Image(systemName: "globe")
                            .onTapGesture {
                                if let tileIndex = mapCoordinator.overlays.firstIndex(where: { $0.id == "openStreet"}) {
                                    mapCoordinator.overlays.remove(at: tileIndex)
                                    text = "Back to Apple Tileset"
                                }else{
                                    mapCoordinator.overlays.append(
                                        MapTileOverlay(id: "openStreet",service: .openStreet)
                                    )
                                    text = "Set Open Street Tileset"
                                }
                                //mapCoordinator.overlays = []
                            }
                        Image(systemName: "photo.fill")
                            .onTapGesture {
                                if let image = UIImage(named: "usaMap") {
                                    mapCoordinator.overlays.append(
                                        MapImageOverlay(
                                            location: .init(coordinates: mapCoordinator.tapLocation.coordinates),
                                            image: image
                                        )
                                    )
                                }
                            }
                        Image(systemName: "mappin.slash")
                            .onTapGesture {
                                mapCoordinator.locations = []
                                text = "Removed all locations"
                            }
                        Image(systemName: "circle.slash")
                            .onTapGesture {
                                mapCoordinator.overlays = []
                                text = "Removed all overlays"
                            }
                        Image(systemName: "line.diagonal")
                            .onTapGesture {
                                if mapCoordinator.locations.count > 1 {
                                    mapCoordinator.overlays = []
                                    let lineCoords = mapCoordinator.locations.map { loc in
                                        loc.coordinates
                                    }
                                    mapCoordinator.overlays.append(
                                        MapLineOverlay(coordinates: lineCoords)
                                    )
                                    text = "Drawed a line between annotations"
                                } else {
                                    text = "Add at least 2 locations to draw a line between them"
                                }
                            }
                            .padding(.trailing)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
                    .frame(width: 50)
                    .padding()
                }
            }
            .onChange(of: mapCoordinator.tapLocation) { newValue in
                mapCoordinator.locations.append(
                    newValue.with(clusterId: "clusteredAnn",view: TestAnnotationView())
                )
            }
        }
        .padding()
    }
}

struct TestAnnotationView : SwiftUIMapAnnotationView {
    
    @ObservedObject var annCoordinator: AnnotationCoordinator = .init(frame: .init(x: 0, y: 0, width: 100, height: 100))
    
    var body: some View {
        ZStack{
            Circle()
                .fill(annCoordinator.isSelected ? .green : .blue)
                .opacity(0.5)
                .onTapGesture {
                    print("circle ann was tapped!")
                    annCoordinator.isSelected.toggle()
                }
        }
        .onChange(of: annCoordinator.isSelected) { newValue in
            var frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            if newValue {
                frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            }
            annCoordinator.frame = frame
        }
    }
}

struct TestClusterView : SwiftUIMapAnnotationView {
    
    @ObservedObject var annCoordinator: AnnotationCoordinator = .init()
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(annCoordinator.isSelected ? .orange : .red)
                .opacity(0.5)
                .onTapGesture {
                    print("circle ann was tapped!")
                    annCoordinator.isSelected.toggle()
                }
        }
        .onChange(of: annCoordinator.isSelected) { newValue in
            var frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            if newValue {
                frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            }
            annCoordinator.frame = frame
        }
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
