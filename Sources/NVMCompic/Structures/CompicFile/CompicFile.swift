//
//  CompicFile.swift
//  
//
//  Created by Damian Van de Kauter on 04/04/2022.
//

import Foundation

public struct CompicFile: Codable {
    public var objectId: String
    public var updatedAt: Date
    
    public var storedAt: Date
    public var usedAt: Date?
    
    public var compicRequest: CompicRequest //Moet iets beter zijn om achteraf nog eens dezelfde request te kunnen opstellen voor elk icon, background & card
    
    public var name: String
    public var url: String
    public var website: String
    public var countries: [String]
    
    public var iconImages: [CompicImage]
    public var backgroundImages: [CompicImage]
    public var cardImages: [CompicImage]
    
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
    
    public init(compic: Compic) {
        self.objectId = compic.objectId
        self.updatedAt = compic.updatedAt
        
        self.storedAt = Date()
        self.usedAt = Date()
        
        self.compicRequest = compic.compicRequest
        
        self.name = compic.name
        self.url = compic.url
        self.website = compic.website
        self.countries = compic.countries
        
        self.iconImages = []
        self.backgroundImages = []
        self.cardImages = []
        
        self.tintColor = compic.tintColor
        self.textColor = compic.textColor
        self.backgroundColor = compic.backgroundColor
        self.buttonColor = compic.buttonColor
        self.fillColor = compic.fillColor
        self.borderColor = compic.borderColor
        self.headerColor = compic.headerColor
        
        try? self.saveCompic(compic)
    }
    
    internal func save() throws {
        let compicPath = try NVMCompic.sharedInstance.getCompicPath()
        let compicFileURL = compicPath.appendingPathComponent(url.toFileName)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .nvmDateStrategySince1970
        
        let compicFileData = try encoder.encode(self)
        try compicFileData.write(to: compicFileURL)
    }
    
    public mutating func saveCompic(_ compic: Compic) throws {
        if let compicIconImage = compic.iconImage {
            self.iconImages.append(CompicImage(type: .icon,
                                               data: compicIconImage,
                                               compicRequest: compic.compicRequest,
                                               format: compic.compicRequest.iconFormat,
                                               resizeType: compic.compicRequest.iconResizeType,
                                               width: compic.compicRequest.iconWidth,
                                               height: compic.compicRequest.iconHeight))
        }
        if let compicBackgroundImage = compic.backgroundImage {
            self.backgroundImages.append(CompicImage(type: .background,
                                                     data: compicBackgroundImage,
                                                     compicRequest: compic.compicRequest,
                                                     format: compic.compicRequest.backgroundFormat,
                                                     resizeType: compic.compicRequest.backgroundResizeType,
                                                     width: compic.compicRequest.backgroundWidth,
                                                     height: compic.compicRequest.backgroundHeight))
        }
        if let compicCardImage = compic.cardImage {
            self.backgroundImages.append(CompicImage(type: .card,
                                                     data: compicCardImage,
                                                     compicRequest: compic.compicRequest,
                                                     format: compic.compicRequest.cardFormat,
                                                     resizeType: compic.compicRequest.cardResizeType,
                                                     width: compic.compicRequest.cardWidth,
                                                     height: compic.compicRequest.cardHeight))
        }
        
        if ((compic.compicRequest.info == nil) || (compic.compicRequest.info == true)) {
            self.name = compic.name
            self.url = compic.url
            self.website = compic.website
            self.countries = compic.countries
        }
        if ((compic.compicRequest.colors == nil) || (compic.compicRequest.colors == true)) {
            self.tintColor = compic.tintColor
            self.textColor = compic.textColor
            self.backgroundColor = compic.backgroundColor
            self.buttonColor = compic.buttonColor
            self.fillColor = compic.fillColor
            self.borderColor = compic.borderColor
            self.headerColor = compic.headerColor
        }
        
        try self.save()
    }
}

extension CompicFile {
    public func compic(request: CompicRequest) -> Compic? {
        return Compic(compicFile: self, compicRequest: request)
    }
}
