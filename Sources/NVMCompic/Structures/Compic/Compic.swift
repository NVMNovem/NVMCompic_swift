//
//  Compic.swift
//  
//
//  Created by Damian Van de Kauter on 30/03/2022.
//

import Foundation
import SwiftUI
import NVMColor

public struct Compic {
    public var objectId: String
    public var updatedAt: Date
    
    public var storedAt: Date
    public var usedAt: Date?
    
    public var compicRequest: CompicRequest
    
    public var name: String
    public var url: String
    public var website: String
    public var countries: [String]
    
    public var iconSpan: Int
    public var tileable: Bool
    
    public var iconImage: Data?
    public var backgroundImage: Data?
    
    public var tintColor: Color?
    public var textColor: Color?
    public var backgroundColor: Color?
    public var buttonColor: Color?
    public var fillColor: Color?
    public var borderColor: Color?
    public var headerColor: Color?
    
    /**
     JSON Data of specific Novem variables
     
     - warning: U need a secret key to access this variable.
     */
    public var nvmData: Data?
    
    enum CodingKeys: String, CodingKey {
        case objectId
        case updatedAt
        
        case storedAt
        case usedAt
        
        case compicRequest
        
        case name
        case url
        case website
        case countries
        
        case iconSpan
        case tileable
        
        case iconImage
        case backgroundImage
        
        case tintColor
        case textColor
        case backgroundColor
        case buttonColor
        case fillColor
        case borderColor
        case headerColor
        
        case nvmData
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
                  
                  iconSpan: Int,
                  tileable: Bool,
                  
                  iconImage: Data?,
                  backgroundImage: Data?,
    
                  tintColor: Color?,
                  textColor: Color?,
                  backgroundColor: Color?,
                  buttonColor: Color?,
                  fillColor: Color?,
                  borderColor: Color?,
                  headerColor: Color?,
    
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
        self.tileable = tileable
        
        self.iconImage = iconImage
        self.backgroundImage = backgroundImage
        
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
        self.tileable = compicFile.tileable
        
        let compicFileIcon = compicFile.iconImages.first(where: { compicImage in
            return compicImage.compicRequest == compicRequest
        })?.data
        let compicFileBackground = compicFile.backgroundImages.first(where: { compicImage in
            compicImage.compicRequest == compicRequest
        })?.data
        
        if ((compicFileIcon != nil) || (compicFileBackground != nil)) {
            self.iconImage = compicFileIcon
            self.backgroundImage = compicFileBackground
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

extension Compic: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(objectId, forKey: .objectId)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        try container.encode(storedAt, forKey: .storedAt)
        try? container.encode(usedAt, forKey: .usedAt)
        
        try container.encode(compicRequest, forKey: .compicRequest)
        
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(website, forKey: .website)
        try container.encode(countries, forKey: .countries)
        
        try container.encode(iconSpan, forKey: .iconSpan)
        try container.encode(tileable, forKey: .tileable)
        
        try? container.encode(iconImage, forKey: .iconImage)
        try? container.encode(backgroundImage, forKey: .backgroundImage)
        
        try? container.encode(tintColor?.hex, forKey: .tintColor)
        try? container.encode(textColor?.hex, forKey: .textColor)
        try? container.encode(backgroundColor?.hex, forKey: .backgroundColor)
        try? container.encode(buttonColor?.hex, forKey: .buttonColor)
        try? container.encode(fillColor?.hex, forKey: .fillColor)
        try? container.encode(borderColor?.hex, forKey: .borderColor)
        try? container.encode(headerColor?.hex, forKey: .headerColor)
        
        try? container.encode(nvmData, forKey: .nvmData)
    }
}
extension Compic: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        objectId = try values.decode(String.self, forKey: .objectId)
        updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        
        do { storedAt = try values.decode(Date.self, forKey: .storedAt) }
        catch { storedAt = Date() }
        usedAt = try? values.decode(Date.self, forKey: .usedAt)
        
        compicRequest = try values.decode(CompicRequest.self, forKey: .compicRequest)
        
        name = try values.decode(String.self, forKey: .name)
        url = try values.decode(String.self, forKey: .url)
        website = try values.decode(String.self, forKey: .website)
        countries = try values.decode([String].self, forKey: .countries)
        
        iconSpan = try values.decode(Int.self, forKey: .iconSpan)
        tileable = try values.decode(Bool.self, forKey: .tileable)
        
        iconImage = try? values.decode(Data.self, forKey: .iconImage)
        backgroundImage = try? values.decode(Data.self, forKey: .backgroundImage)
        
        tintColor = Color(hex: try values.decode(String.self, forKey: .tintColor))
        textColor = Color(hex: try? values.decode(String.self, forKey: .textColor))
        backgroundColor = Color(hex: try? values.decode(String.self, forKey: .backgroundColor))
        buttonColor = Color(hex: try? values.decode(String.self, forKey: .buttonColor))
        fillColor = Color(hex: try? values.decode(String.self, forKey: .fillColor))
        borderColor = Color(hex: try? values.decode(String.self, forKey: .borderColor))
        headerColor = Color(hex: try? values.decode(String.self, forKey: .headerColor))
        
        nvmData = try? values.decode(Data.self, forKey: .nvmData)
    }
}

extension Compic: CustomStringConvertible {
    public var description: String {
        return "\r  [\(self.objectId)]\r  \r  \(self.name)\r  Url: \(self.url)\r  Website: \(self.website)\r  Countries: \(self.countries)\r  Icon Image: \(String(describing: self.iconImage))\r  Background Image: \(String(describing: self.backgroundImage))\r\r  CompicRequest: \(String(describing: self.compicRequest))\r\r  NVMData: \(String(describing: self.nvmData))\r\r  Updated At: \(String(describing: self.updatedAt))\r"
    }
}
