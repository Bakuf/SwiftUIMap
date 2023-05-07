//
//  TileSet.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import Foundation

class TileSet {
    
    struct Constant {
        static let downloadLimit = 1000
        static let waitTime : Double = 5
    }
    
    struct TilePath {
        var z : Int
        var x : Int
        var y : Int
        
        func path(for service: TileService) -> String {
            service.pathFor(z: z, x: x, y: y)
        }
    }
    
    internal init(for service: TileService, zoomLevel: Int) {
        self.zoomLevel = zoomLevel
        self.service = service
        self.tilesNeeded = 0
        getTilesToDownload()
    }
    
    var zoomLevel : Int
    var paths : [TilePath] = []
    var service : TileService
    var finishedCallback : (()->Void)?
    
    var tilesNeeded : Int {
        didSet {
            print("tiles in this pass : \(tilesNeeded)")
            if tilesNeeded == 0 {
                downloading = false
                if paths.count == 0 {
                    print("finish downloading tiles for zoomLevel \(zoomLevel) in service : \(service.template)")
                    finishedCallback?()
                }else{
                    print("need another pass(\(pass)) will wait \(Constant.waitTime) seconds")
                    TileSet.performAfterDelay {
                        self.download()
                    }
                }
            }
        }
    }
    var pass = 0
    var downloading : Bool = false
    
    func getTilesToDownload() {
        let tileLine = Int(pow(2,Double(zoomLevel)))
        for x in 0...(tileLine - 1) {
            for y in 0...(tileLine - 1) {
                paths.append(TilePath(z: zoomLevel, x: x, y: y))
            }
        }
    }
    
    func download() {
        if !downloading {
            if pass == 0 { print("will download \(paths.count) for zoomLevel \(zoomLevel) in service : \(service.template)") }
            pass += 1
            var limit = Constant.downloadLimit
            if paths.count < Constant.downloadLimit {
                limit = paths.count
            }
            tilesNeeded = limit
            for _ in 0...(limit - 1) {
                if let path = paths.popLast() {
                    let url = URL(string: path.path(for: service))!
                    TileDownloader.downloadTile(url: url, to: .disk) { _,_ in
                        DispatchQueue.main.sync {[weak self] in
                            self?.tilesNeeded -= 1
                        }
                    }
                }
            }
        }
    }
    
    class func performAfterDelay(completion: @escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constant.waitTime) {
            if Thread.isMainThread {
                completion()
            }else{
                DispatchQueue.main.sync {
                    completion()
                }
            }
        }
    }
    
}
