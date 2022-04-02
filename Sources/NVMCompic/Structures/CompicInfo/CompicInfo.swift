//
//  CompicInfo.swift
//  
//
//  Created by Damian Van de Kauter on 02/04/2022.
//

import Foundation

public struct CompicInfo: Codable {
    public var objectId: String
    
    public var updatedAt: Date?
    public var name: String?
    public var url: String?
    public var website: String?
    public var countries: [String]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        objectId = try container.decode(String.self, forKey: .objectId)
        
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        name = try? container.decode(String.self, forKey: .name)
        url = try? container.decode(String.self, forKey: .url)
        website = try? container.decode(String.self, forKey: .website)
        countries = try? container.decode([String].self, forKey: .countries)
    }
}
