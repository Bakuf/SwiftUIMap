//
//  TileDownloader.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import MapKit

class TileDownloader {
    
    internal init(for service: TileService, storage : StorageType) {
        self.service = service
        self.storage = storage
    }
    
    var service : TileService
    var storage : StorageType
    
    var tileSets : [TileSet] = []
    func download(serviceUrl: String, until zoomLevel: Int){
        if zoomLevel == 0 {
            TileSet(for: service, zoomLevel: 0).download()
        }else{
            for t in 0...zoomLevel {
                let zoomLevel = TileSet(for: service, zoomLevel: t)
                zoomLevel.finishedCallback = { [weak self] in
                    self?.didFinishDownload()
                }
                tileSets.append(zoomLevel)
            }
            let zoomLevel = tileSets.popLast()
            zoomLevel?.download()
        }
    }

    func didFinishDownload() {
        print("will wait \(TileSet.Constant.waitTime) seconds")
        if tileSets.count == 0 {
            print("Finish downloading all tiles! :D")
            return
        }
        TileSet.performAfterDelay {[weak self] in
            let zoomLevel = self?.tileSets.popLast()
            zoomLevel?.download()
        }
    }
    
    static func downloadTile(url: URL,to storage: StorageType, result:  ((Data?, Error?) -> Void)? = nil) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                        TileCache.shared.save(data: data, to: storage, with: url.absoluteString)
                        print("Succesful download for tile : \(url.lastPathComponent)")
                        if let result = result {
                            result(data, error)
                        }
                    }else{
                        print("Could not download tile(\(url.absoluteString)) got status \(httpResponse.statusCode)")
                        if let result = result {
                            result(nil, error)
                        }
                    }
                }else{
                    print("Could not download tile(\(url.absoluteString)) response was not http")
                    if let result = result {
                        result(nil, error)
                    }
                }
            }
            if error != nil {
                print("Error downloading tile\(url.absoluteString) : \(error?.localizedDescription ?? "none")")
                if let result = result {
                    result(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func downloadTile(url: URL, result:  ((Data?, Error?) -> Void)? = nil) {
        TileDownloader.downloadTile(url: url, to: storage, result: result)
    }
    
}
