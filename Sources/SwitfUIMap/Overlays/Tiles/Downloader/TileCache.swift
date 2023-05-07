//
//  TileCache.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import Foundation

public enum StorageType {
    case cache//Ram Memory, only available for this session
    case temp//Temp directory, cleaned by the system
    case disk//Permanent disc
}

public enum StorageStatus {
    case notFound
    case onCache
    case onTempDir
    case onDocumentsDir
}

class TileCache {
    
    static let shared = TileCache()
    let tilesCache = WrappedCache<String, Data>()
    
    struct constants {
        static let tempDirectoryFolder = "MapTilesTemp"
        static let documentsDirectoryFolder = "MapTiles"
    }
    
    static let tempDirectoryPath : URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory,
                                             in: .userDomainMask)
        return paths[0].appendingPathComponent(constants.tempDirectoryFolder)
    }()
    
    static let documentsDirectoryPath : URL = {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0].appendingPathComponent(constants.documentsDirectoryFolder)
    }()
    
    
}

extension TileCache {
    
    func getDownloadStatus(for identifier:String) -> StorageStatus {
        let tempPath = TileCache.tempDirectoryPath.appendingPathComponent(identifier)
        let documentPath = TileCache.documentsDirectoryPath.appendingPathComponent(identifier)
        if TileCache.shared.tilesCache[identifier] != nil {
            return .onCache
        }else if FileManager.default.fileExists(atPath: tempPath.path) {
            return .onTempDir
        }else if FileManager.default.fileExists(atPath: documentPath.path){
            return .onDocumentsDir
        }else{
            return .notFound
        }
    }
    
    func clearContent(of storage : StorageType){
        var url : URL? = nil
        switch storage {
        case .cache:
            TileCache.shared.tilesCache.removeAllValues()
        case .temp:
            url = TileCache.tempDirectoryPath
        case .disk:
            url = TileCache.documentsDirectoryPath
        }
        guard let dirURL = url else {
            return
        }
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: dirURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func save(data: Data, to storage: StorageType, with identifier: String){
        //We always store in volatile session cache
        print("saving data : \(data.mbSize)")
        TileCache.shared.tilesCache[identifier] = data
        switch storage {
        case .temp:
            let tempPath = TileCache.tempDirectoryPath.appendingPathComponent(identifier)
            try? FileManager.default.createDirectory(at: tempPath.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            do {
                try data.write(to: tempPath)
                //print("saved data to : \(cachePath.path)")
            } catch {
                print("Error saving data to path : \(tempPath) \(error)")
            }
        case .disk:
            let documentPath = TileCache.documentsDirectoryPath.appendingPathComponent(identifier)
            try? FileManager.default.createDirectory(at: documentPath.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            do {
                try data.write(to: documentPath)
            } catch {
                print("Error saving data to path : \(documentPath) \(error)")
            }
        default:
            //do nothing
            break
        }
    }
    
    func getData(for identifier:String) -> Data? {
        //If it is on cache, return it
        if let data = TileCache.shared.tilesCache[identifier] {
            return data
        }
        
        //It's not on cache so look for it on temp and then disk
        var data : Data? = nil
        switch getDownloadStatus(for: identifier) {
        case .onTempDir :
            let cachePath = TileCache.tempDirectoryPath.appendingPathComponent(identifier)
            data = FileManager.default.contents(atPath: cachePath.path)
        case .onDocumentsDir:
            let documentPath = TileCache.documentsDirectoryPath.appendingPathComponent(identifier)
            data = FileManager.default.contents(atPath: documentPath.path)
        default:
            //nothing to do, will return nil
            break
        }
        
        //Save to cache if found so its easily available next time
        if let data = data {
            TileCache.shared.tilesCache[identifier] = data
        }
        
        return data
    }
}


