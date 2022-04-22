//
//  CompicFile.swift
//  
//
//  Created by Damian Van de Kauter on 04/04/2022.
//

import Foundation
import SwiftUI
import NVMColor

public struct CompicFile: Hashable {
    public var objectId: String
    public var updatedAt: Date
    
    public var storedAt: Date
    public var usedAt: Date?
    
    public var name: String
    public var url: String
    public var website: String
    public var countries: [String]
    
    public var iconSpan: Int
    public var tileable: Bool
    
    public var iconImages: [CompicImage]
    public var backgroundImages: [CompicImage]
    
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
    
    public static func == (lhs: CompicFile, rhs: CompicFile) -> Bool {
        return lhs.objectId == rhs.objectId
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectId)
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId
        case updatedAt
        
        case storedAt
        case usedAt
        
        case name
        case url
        case website
        case countries
        
        case iconSpan
        case tileable
        
        case iconImages
        case backgroundImages
        
        case tintColor
        case textColor
        case backgroundColor
        case buttonColor
        case fillColor
        case borderColor
        case headerColor
        
        case nvmData
    }
    
    public init(compic: Compic) {
        self.objectId = compic.objectId
        self.updatedAt = compic.updatedAt
        
        self.storedAt = Date()
        self.usedAt = Date()
        
        self.name = compic.name
        self.url = compic.url
        self.website = compic.website
        self.countries = compic.countries
        
        self.iconSpan = compic.iconSpan
        self.tileable = compic.tileable
        
        self.iconImages = []
        self.backgroundImages = []
        
        self.tintColor = compic.tintColor
        self.textColor = compic.textColor
        self.backgroundColor = compic.backgroundColor
        self.buttonColor = compic.buttonColor
        self.fillColor = compic.fillColor
        self.borderColor = compic.borderColor
        self.headerColor = compic.headerColor
        
        try? self.saveCompic(compic)
    }
    
    internal func allRequests() -> [CompicRequest] {
        var compicRequests: [CompicRequest] = []
        compicRequests.append(contentsOf: self.iconImages.map({ compicImage in
            compicImage.compicRequest
        }))
        compicRequests.append(contentsOf: self.backgroundImages.map({ compicImage in
            compicImage.compicRequest
        }))
        
        return compicRequests
    }
    
    internal mutating func save() throws {
        let compicPath = try NVMCompic.sharedInstance.getCompicPath()
        let compicFileURL = compicPath.appendingPathComponent(url.toFileName)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .nvmDateStrategySince1970
        
        let compicFileData = try encoder.encode(self)
        try compicFileData.write(to: compicFileURL)
    }
    
    public mutating func saveCompic(_ compic: Compic) throws {
        if let compicIconImage = compic.iconImage {
            self.iconImages.removeAll(where: { compicImage in
                compicImage.compicRequest == compic.compicRequest
            })
            self.iconImages.append(CompicImage(type: .icon,
                                               data: compicIconImage,
                                               compicRequest: compic.compicRequest,
                                               format: compic.compicRequest.iconFormat,
                                               resizeType: compic.compicRequest.iconResizeType,
                                               width: compic.compicRequest.iconWidth,
                                               height: compic.compicRequest.iconHeight))
        }
        if let compicBackgroundImage = compic.backgroundImage {
            self.backgroundImages.removeAll(where: { compicImage in
                compicImage.compicRequest == compic.compicRequest
            })
            self.backgroundImages.append(CompicImage(type: .background,
                                                     data: compicBackgroundImage,
                                                     compicRequest: compic.compicRequest,
                                                     format: compic.compicRequest.backgroundFormat,
                                                     resizeType: compic.compicRequest.backgroundResizeType,
                                                     width: compic.compicRequest.backgroundWidth,
                                                     height: compic.compicRequest.backgroundHeight))
        }
        
        self.iconSpan = compic.iconSpan
        self.tileable = compic.tileable
        
        self.name = compic.name
        self.url = compic.url
        self.website = compic.website
        self.countries = compic.countries
        
        if ((compic.compicRequest.colors == nil) || (compic.compicRequest.colors == true)) {
            self.tintColor = compic.tintColor
            self.textColor = compic.textColor
            self.backgroundColor = compic.backgroundColor
            self.buttonColor = compic.buttonColor
            self.fillColor = compic.fillColor
            self.borderColor = compic.borderColor
            self.headerColor = compic.headerColor
        } else {
            if let compicTintColor = compic.tintColor {
                self.tintColor = compicTintColor
            }
            if let compicTextColor = compic.textColor {
                self.textColor = compicTextColor
            }
            if let compicBackgroundColor = compic.backgroundColor {
                self.backgroundColor = compicBackgroundColor
            }
            if let compicButtonColor = compic.buttonColor {
                self.buttonColor = compicButtonColor
            }
            if let compicFillColor = compic.fillColor {
                self.fillColor = compicFillColor
            }
            if let compicBorderColor = compic.borderColor {
                self.borderColor = compicBorderColor
            }
            if let compicHeaderColor = compic.headerColor {
                self.headerColor = compicHeaderColor
            }
        }
        
        self.updatedAt = compic.updatedAt
        
        try self.save()
    }
}

extension CompicFile: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(objectId, forKey: .objectId)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        try container.encode(storedAt, forKey: .storedAt)
        try? container.encode(usedAt, forKey: .usedAt)
        
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(website, forKey: .website)
        try container.encode(countries, forKey: .countries)
        
        try container.encode(iconSpan, forKey: .iconSpan)
        try container.encode(tileable, forKey: .tileable)
        
        try? container.encode(iconImages, forKey: .iconImages)
        try? container.encode(backgroundImages, forKey: .backgroundImages)
        
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
extension CompicFile: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        objectId = try values.decode(String.self, forKey: .objectId)
        updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        
        storedAt = try values.decode(Date.self, forKey: .storedAt)
        usedAt = try? values.decode(Date.self, forKey: .usedAt)
        
        name = try values.decode(String.self, forKey: .name)
        url = try values.decode(String.self, forKey: .url)
        website = try values.decode(String.self, forKey: .website)
        countries = try values.decode([String].self, forKey: .countries)
        
        iconSpan = try values.decode(Int.self, forKey: .iconSpan)
        tileable = try values.decode(Bool.self, forKey: .tileable)
        
        iconImages = (try? values.decode([CompicImage].self, forKey: .iconImages)) ?? []
        backgroundImages = (try? values.decode([CompicImage].self, forKey: .backgroundImages)) ?? []
        
        tintColor = Color(hex: try? values.decode(String.self, forKey: .tintColor))
        textColor = Color(hex: try? values.decode(String.self, forKey: .textColor))
        backgroundColor = Color(hex: try? values.decode(String.self, forKey: .backgroundColor))
        buttonColor = Color(hex: try? values.decode(String.self, forKey: .buttonColor))
        fillColor = Color(hex: try? values.decode(String.self, forKey: .fillColor))
        borderColor = Color(hex: try? values.decode(String.self, forKey: .borderColor))
        headerColor = Color(hex: try? values.decode(String.self, forKey: .headerColor))
        
        nvmData = try? values.decode(Data.self, forKey: .nvmData)
    }
}

extension CompicFile {
    public func compic(request: CompicRequest) -> Compic? {
        return Compic(compicFile: self, compicRequest: request)
    }
}
