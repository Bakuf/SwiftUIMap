# SwitfUIMap ![Platform](https://img.shields.io/badge/Platforms-%20iOS%20-lightgrey.svg) ![Swift 5](https://img.shields.io/badge/Swift-5-F28D00.svg) [![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

SwiftUI Wrapper for MapKit

Features :

- Custom Annotations and Clusters
- Images, lines, circles and polygon overlays
- Custom tile sets and cache management
- Region lock and zoom control

## Quick Start

Just import MapKit and SwitfUIMap to your swiftUI view and create both a `MapCoordinator` and a `SwitfUIMap` view inside

```swift
@StateObject var mapCoordinator = MapCoordinator()

let applePark : CLLocationCoordinate2D = .init(latitude: 37.334600, longitude: -122.009200)

var body: some View {
    SwitfUIMap(coordinator: mapCoordinator).onAppear{
        mapCoordinator.setCenterCoordinate(coordinate: applePark, zoomLevel: 16, animated: true)
    }
}
```

To add annotations you need to create a `MapLocation` with the CLLocationCoordinate2D that you want and add it to the array of locations inside the `MapCoordinator`

```swift
mapCoordinator.locations.append(
    MapLocation(coordinates: applePark, view: CoolAnnotationView())
)
```

Any annotation that is added or deleted to the array will be automatically managed by the map view, if you need to modify or delete one, you can search them by setting the id property inside MapLocation.

The view paramater is optional, but needed for a custom annotation view. To use it your swiftUI view needs to conform to the `SwiftUIMapAnnotationView` protocol that only requires one property of type `AnnotationCoordinator` to be added.

```swift
struct CoolAnnotationView : SwiftUIMapAnnotationView {
    
    @ObservedObject var annCoordinator = AnnotationCoordinator(frame: .init(x: 0, y: 0, width: 100, height: 100))
    
    var body: some View {
        ZStack{
            Circle()
                .fill(annCoordinator.isSelected ? .green : .blue)
        }
    }

}
```

If you want to know how to use the other features check out the example project.


## Installation

`SwitfUIMap` can be installed using [Swift Package Manager](https://swift.org/package-manager/), or manually.

### Swift Package Manager

[Swift Package Manager](https://github.com/apple/swift-package-manager) requires Swift version 4.0 or higher. First, create a `Package.swift` file. It should look like:

```swift
dependencies: [
    .package(url: "https://github.com/Bakuf/SwiftUIMap.git", from: "0.0.1")
]
```

`swift build` should then pull in and compile `SwitfUIMap` for you to begin using.


## License

SwitfUIMap is available under the MIT license. See [the LICENSE file](./license.txt) for more information.

