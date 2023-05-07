//
//  MapTileOverlay.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

public class MapTileOverlay : MKTileOverlay, MapOverlay {
    
    public var id: String
    public var type: MapOverlayType { .tileService }
    public var level: MKOverlayLevel
    var tileDownloader : TileDownloader

    public init(id: String = UUID().uuidString, service: TileService, canReplaceMapContent: Bool = true, level: MKOverlayLevel = .aboveRoads, isGeometryFlipped: Bool = false) {
        self.id = id
        self.level = level
        self.tileDownloader = .init(for: service, storage: .cache)
        super.init(urlTemplate: nil)
        
        self.isGeometryFlipped = isGeometryFlipped
        self.canReplaceMapContent = canReplaceMapContent
        
//        tileDownloader = TileDownloader()
//        tileDownloader?.download(serviceUrl: "https://swissgameguides.media/games/forza_horizon_5/media/tiles/T_1/%d/%d/%d.jpg", until: 6)
    }

    public override func url(forTilePath path: MKTileOverlayPath) -> URL {
        return URL(string: path.TilePath.path(for: tileDownloader.service))!
    }
    
    public override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = url(forTilePath: path)
        tileDownloader.downloadTile(url: url) { data, error in
            if let data = data {
                result(data,nil)
            }else{
                result(nil,nil)
            }
        }
    }
    
}

extension MapTileOverlay : MapOverlayRenderProvider {
    var renderer: MKOverlayRenderer { MKTileOverlayRenderer(overlay: self) }
}

extension MKTileOverlayPath {
    var TilePath : TileSet.TilePath { .init(z: z, x: x, y: y) }
}
