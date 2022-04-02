//
//  Compic.swift
//  
//
//  Created by Damian Van de Kauter on 30/03/2022.
//

import Foundation

public struct Compic: Codable {
    public var objectId: String
    public var updatedAt: Date
    
    public var storedAt: Date
    public var usedAt: Date?
    
    public var compicRequest: CompicRequest
    
    public var name: String
    public var url: String
    public var website: String
    public var countries: [String]
    
    public var iconImage: Data
    public var backgroundImage: Data
    public var cardImage: Data?
    
    public var tintColor: String?
    public var textColor: String?
    public var backgroundColor: String?
    public var buttonColor: String?
    public var fillColor: String?
    public var borderColor: String?
    public var headerColor: String?
    
    /**
     JSON Data of specific Novem variables
     
     - warning: U need a secret key to access this variable.
     */
    public var nvmData: Data?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        objectId = try container.decode(String.self, forKey: .objectId)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        do { storedAt = try container.decode(Date.self, forKey: .storedAt) }
        catch { storedAt = Date() }
        usedAt = try? container.decode(Date.self, forKey: .usedAt)
        
        compicRequest = try container.decode(CompicRequest.self, forKey: .compicRequest)
        
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        website = try container.decode(String.self, forKey: .website)
        countries = try container.decode([String].self, forKey: .countries)
        
        iconImage = try container.decode(Data.self, forKey: .iconImage)
        backgroundImage = try container.decode(Data.self, forKey: .backgroundImage)
        cardImage = try? container.decode(Data.self, forKey: .cardImage)
        
        tintColor = try? container.decode(String.self, forKey: .tintColor)
        textColor = try? container.decode(String.self, forKey: .textColor)
        backgroundColor = try? container.decode(String.self, forKey: .backgroundColor)
        buttonColor = try? container.decode(String.self, forKey: .buttonColor)
        fillColor = try? container.decode(String.self, forKey: .fillColor)
        borderColor = try? container.decode(String.self, forKey: .borderColor)
        headerColor = try? container.decode(String.self, forKey: .headerColor)
        
        nvmData = try? container.decode(Data.self, forKey: .nvmData)
    }
}


extension Compic: CustomStringConvertible {
    public var description: String {
        return "\r  \(self.name)\r  Url: \(self.url)\r  Website: \(self.website)\r  Countries: \(self.countries)\r  Icon Image: \(self.iconImage)\r  Background Image: \(self.backgroundImage)\r  Card Image: \(String(describing: self.cardImage))\r\r  Tint Color: \(String(describing: self.tintColor))\r  Text Color: \(String(describing: self.textColor))\r  Background Color: \(String(describing: self.backgroundColor))\r  Button Color: \(String(describing: self.buttonColor))\r  Fill Color: \(String(describing: self.fillColor))\r  Border Color: \(String(describing: self.borderColor))\r  Header Color: \(String(describing: self.headerColor))\r\r  CompicRequest: \(String(describing: self.compicRequest))\r\r  NVMData: \(String(describing: self.nvmData))\r"
    }
}
