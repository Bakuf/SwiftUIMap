//
//  TileTemplate.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import Foundation


public struct TileService {
    public init(template: String) {
        self.template = template
    }
    
    let template: String
}

public extension TileService {
    static var openStreet : TileService { .init(template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png") }
}

extension TileService {
    func pathFor(z: Int, x: Int, y: Int) -> String {
        var filledTemplate = template.replacingOccurrences(of: "{z}", with: "\(z)")
        filledTemplate = filledTemplate.replacingOccurrences(of: "{x}", with: "\(x)")
        return filledTemplate.replacingOccurrences(of: "{y}", with: "\(y)")
    }
}
