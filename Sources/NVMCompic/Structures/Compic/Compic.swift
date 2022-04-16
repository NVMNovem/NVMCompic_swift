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
    
    public var iconSpan: Int?
    
    public var iconImage: Data?
    public var backgroundImage: Data?
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
        
        iconSpan = try container.decode(Int.self, forKey: .iconSpan)
        
        iconImage = try? container.decode(Data.self, forKey: .iconImage)
        backgroundImage = try? container.decode(Data.self, forKey: .backgroundImage)
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
    
    internal init(objectId: String,
                  updatedAt: Date,
                  
                  storedAt: Date = Date(),
                  usedAt: Date? = nil,
    
                  compicRequest: CompicRequest,
    
                  name: String,
                  url: String,
                  website: String,
                  countries: [String],
                  
                  iconSpan: Int?,
                  
                  iconImage: Data?,
                  backgroundImage: Data?,
                  cardImage: Data?,
    
                  tintColor: String?,
                  textColor: String?,
                  backgroundColor: String?,
                  buttonColor: String?,
                  fillColor: String?,
                  borderColor: String?,
                  headerColor: String?,
    
                  nvmData: Data?) {
        
        self.objectId = objectId
        self.updatedAt = updatedAt
        
        self.storedAt = storedAt
        self.usedAt = usedAt
        
        self.compicRequest = compicRequest
        
        self.name = name
        self.url = url
        self.website = website
        self.countries = countries
        
        self.iconSpan = iconSpan
        
        self.iconImage = iconImage
        self.backgroundImage = backgroundImage
        self.cardImage = cardImage
        
        self.tintColor = tintColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.buttonColor = buttonColor
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.headerColor = headerColor
        
        self.nvmData = nvmData
    }
    
    internal init?(compicFile: CompicFile?, compicRequest: CompicRequest?) {
        guard let compicFile = compicFile else { return nil }
        guard let compicRequest = compicRequest else { return nil }
        
        self.objectId = compicFile.objectId
        self.updatedAt = compicFile.updatedAt
        
        self.storedAt = compicFile.storedAt
        self.usedAt = compicFile.usedAt
        
        self.compicRequest = compicRequest
        
        self.name = compicFile.name
        self.url = compicFile.url
        self.website = compicFile.website
        self.countries = compicFile.countries
               
        self.iconSpan = compicFile.iconSpan
        
        let compicFileIcon = compicFile.iconImages.first(where: { compicImage in
            return compicImage.compicRequest == compicRequest
        })?.data
        let compicFileBackground = compicFile.backgroundImages.first(where: { compicImage in
            compicImage.compicRequest == compicRequest
        })?.data
        let compicFileCard = compicFile.cardImages.first(where: { compicImage in
            compicImage.compicRequest == compicRequest
        })?.data
        
        if ((compicFileIcon != nil) || (compicFileBackground != nil) || (compicFileCard != nil)) {
            self.iconImage = compicFileIcon
            self.backgroundImage = compicFileBackground
            self.cardImage = compicFileCard
        } else {
            self.iconImage = compicFile.iconImages.first(where: { compicImage in
                compicImage.type == .icon &&
                compicImage.width == compicRequest.iconWidth &&
                compicImage.height == compicRequest.iconHeight &&
                compicImage.format == compicRequest.iconFormat &&
                compicImage.resizeType == compicRequest.iconResizeType
            })?.data
            
            self.backgroundImage = compicFile.backgroundImages.first(where: { compicImage in
                compicImage.type == .background &&
                compicImage.width == compicRequest.backgroundWidth &&
                compicImage.height == compicRequest.backgroundHeight &&
                compicImage.format == compicRequest.backgroundFormat &&
                compicImage.resizeType == compicRequest.backgroundResizeType
            })?.data
            
            self.cardImage = compicFile.cardImages.first(where: { compicImage in
                compicImage.type == .card &&
                compicImage.width == compicRequest.cardWidth &&
                compicImage.height == compicRequest.cardHeight &&
                compicImage.format == compicRequest.cardFormat &&
                compicImage.resizeType == compicRequest.cardResizeType
            })?.data
        }
        
        
        self.tintColor = compicFile.tintColor
        self.textColor = compicFile.textColor
        self.backgroundColor = compicFile.backgroundColor
        self.buttonColor = compicFile.buttonColor
        self.fillColor = compicFile.fillColor
        self.borderColor = compicFile.borderColor
        self.headerColor = compicFile.headerColor
        
        self.nvmData = compicFile.nvmData
    }
    
    internal func getCompicFile() throws -> CompicFile {
        let compicPath = try NVMCompic.sharedInstance.getCompicPath()
        let compicFileURL = compicPath.appendingPathComponent(url.toFileName)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        if FileManager.default.fileExists(atPath: compicFileURL.path), let compicData = try? Data(contentsOf: compicFileURL) {
            var compicFile = try decoder.decode(CompicFile.self, from: compicData)
            compicFile.usedAt = Date()
            
            try compicFile.save()
            
            return compicFile
        } else {
            return CompicFile(compic: self)
        }
    }
    
    public func save() throws {
        var compicFile = try self.getCompicFile()
        try compicFile.saveCompic(self)
    }
}


extension Compic: CustomStringConvertible {
    public var description: String {
        return "\r  [\(self.objectId)]\r  \r  \(self.name)\r  Url: \(self.url)\r  Website: \(self.website)\r  Countries: \(self.countries)\r  Icon Image: \(String(describing: self.iconImage))\r  Background Image: \(String(describing: self.backgroundImage))\r  Card Image: \(String(describing: self.cardImage))\r\r  Tint Color: \(String(describing: self.tintColor))\r  Text Color: \(String(describing: self.textColor))\r  Background Color: \(String(describing: self.backgroundColor))\r  Button Color: \(String(describing: self.buttonColor))\r  Fill Color: \(String(describing: self.fillColor))\r  Border Color: \(String(describing: self.borderColor))\r  Header Color: \(String(describing: self.headerColor))\r\r  CompicRequest: \(String(describing: self.compicRequest))\r\r  NVMData: \(String(describing: self.nvmData))\r\r  Updated At: \(String(describing: self.updatedAt))\r"
    }
}
