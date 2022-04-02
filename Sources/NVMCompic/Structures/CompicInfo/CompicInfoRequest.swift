//
//  CompicInfoRequest.swift
//  
//
//  Created by Damian Van de Kauter on 31/03/2022.
//

import Foundation

public struct CompicInfoRequest: Codable, Equatable {
    public var objectId: String
    public var type: InfoType
    
    public init(objectId: String,
                type: InfoType) {
        self.objectId = objectId
        self.type = type
    }
    
    public enum InfoType: String, Codable {
        case updatedAt
        case name
        case url
        case website
        case countries
    }
}
