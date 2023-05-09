//
//  MapAnchor.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import Foundation

public enum MapAnchor {
    case topLeft
    case top
    case topRight
    case left
    case center
    case right
    case bottomLeft
    case bottom
    case bottomRight
}

extension MapAnchor {
    func getAnnotationPoint(from size: CGSize) -> CGPoint {
        switch self {
        case .topLeft:
            return .init(x: size.width * 0.5, y: size.height * 0.5)
        case .top:
            return .init(x: 0, y: size.height * 0.5)
        case .topRight:
            return .init(x: -(size.width * 0.5), y: size.height * 0.5)
        case .left:
            return .init(x: size.width * 0.5, y: 0)
        case .center:
            return .init(x: 0, y: 0)
        case .right:
            return .init(x: -(size.width * 0.5), y: 0)
        case .bottomLeft:
            return .init(x: size.width * 0.5, y: -(size.height * 0.5))
        case .bottom:
            return .init(x: 0, y: -(size.height * 0.5))
        case .bottomRight:
            return .init(x: -(size.width * 0.5), y: -(size.height * 0.5))
        }
    }
}

extension MapAnchor {
    func getImagePoint(from size: CGSize) -> CGPoint {
        switch self {
        case .topLeft:
            return .init(x: 0, y: -size.height)
        case .top:
            return .init(x: -(size.width * 0.5), y: -size.height)
        case .topRight:
            return .init(x: -size.width, y: -size.height)
        case .left:
            return .init(x: 0, y: -(size.height * 0.5))
        case .center:
            return .init(x: -(size.width * 0.5), y: -(size.height * 0.5))
        case .right:
            return .init(x: -size.width, y: -(size.height * 0.5))
        case .bottomLeft:
            return .init(x: 0, y: 0)
        case .bottom:
            return .init(x: -(size.width * 0.5), y: 0)
        case .bottomRight:
            return .init(x: -size.width, y: 0)
        }
    }
}
