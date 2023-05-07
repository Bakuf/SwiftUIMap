//
//  Data+Extensions.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import Foundation

extension Data {
    
    var mbSize : String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
    }
    
}
