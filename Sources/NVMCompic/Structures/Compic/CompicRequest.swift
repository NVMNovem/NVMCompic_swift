//
//  CompicRequest.swift
//  
//
//  Created by Damian Van de Kauter on 30/03/2022.
//

import Foundation

public struct CompicRequest: Codable, Equatable {
    public var url: String
    
    public var icon: Bool?
    public var iconFormat: NVMCompic.ImageType?
    public var iconResizeType: NVMCompic.ResizeType?
    public var iconWidth: Int?
    public var iconHeight: Int?
    
    public var background: Bool?
    public var backgroundFormat: NVMCompic.ImageType?
    public var backgroundResizeType: NVMCompic.ResizeType?
    public var backgroundWidth: Int?
    public var backgroundHeight: Int?
    
    public var card: Bool?
    public var cardFormat: NVMCompic.ImageType?
    public var cardResizeType: NVMCompic.ResizeType?
    public var cardWidth: Int?
    public var cardHeight: Int?
    
    public var colors: Bool?
    public var info: Bool?
    
    public var nvmSecret: String?
    
    public init(url: String,
                
                icon: Bool? = nil,
                iconFormat: NVMCompic.ImageType? = nil,
                iconResizeType: NVMCompic.ResizeType? = nil,
                iconWidth: Int? = nil,
                iconHeight: Int? = nil,
                
                background: Bool? = nil,
                backgroundFormat: NVMCompic.ImageType? = nil,
                backgroundResizeType: NVMCompic.ResizeType? = nil,
                backgroundWidth: Int? = nil,
                backgroundHeight: Int? = nil,
                
                card: Bool? = nil,
                cardFormat: NVMCompic.ImageType? = nil,
                cardResizeType: NVMCompic.ResizeType? = nil,
                cardWidth: Int? = nil,
                cardHeight: Int? = nil,
                
                colors: Bool? = nil,
                info: Bool? = nil,
                
                nvmSecret: String? = nil) {
        self.url = url
        
        self.icon = icon
        self.iconFormat = iconFormat
        self.iconResizeType = iconResizeType
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
        
        self.background = background
        self.backgroundFormat = backgroundFormat
        self.backgroundResizeType = backgroundResizeType
        self.backgroundWidth = backgroundWidth
        self.backgroundHeight = backgroundHeight
        
        self.card = card
        self.cardFormat = cardFormat
        self.cardResizeType = cardResizeType
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        
        self.colors = colors
        self.info = info
        
        self.nvmSecret = nvmSecret
    }
    
    internal func getFileName() -> String {
        if self.url.count > 100 {
            return (self.getUniqueCompicString().suffix(200) + ".compic")
        } else {
            return (self.getUniqueCompicString().prefix(200) + ".compic")
        }
    }
    
    private func getUniqueCompicString() -> String {
        var uniqueString = self.url
        
        uniqueString += (self.iconFormat?.rawValue ?? "")
        uniqueString += (self.iconResizeType?.rawValue ?? "")
        uniqueString += String(self.iconWidth ?? 0)
        uniqueString += String(self.iconHeight ?? 0)
        
        uniqueString += (self.backgroundFormat?.rawValue ?? "")
        uniqueString += (self.backgroundResizeType?.rawValue ?? "")
        uniqueString += String(self.backgroundWidth ?? 0)
        uniqueString += String(self.backgroundHeight ?? 0)
        
        uniqueString += (self.cardFormat?.rawValue ?? "")
        uniqueString += (self.cardResizeType?.rawValue ?? "")
        uniqueString += String(self.cardWidth ?? 0)
        uniqueString += String(self.cardHeight ?? 0)
        
        return uniqueString.toBase64().replacingOccurrences(of: "[^A-Za-z0-9]+", with: "", options: [.regularExpression])
    }
}

extension CompicRequest {
    internal var compicImageType: CompicImage.ImageType? {
        if ((self.icon == true) && ((self.background == false)) && (self.card == false)) {
            return .icon
        }
        else if ((self.icon == false) && ((self.background == true)) && (self.card == false)) {
            return .background
        }
        else if ((self.icon == false) && ((self.background == false)) && (self.card == true)) {
            return .card
        }
        else {
            return nil
        }
    }
}
