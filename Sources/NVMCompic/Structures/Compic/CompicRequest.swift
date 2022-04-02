//
//  CompicRequest.swift
//  
//
//  Created by Damian Van de Kauter on 30/03/2022.
//

import Foundation

public struct CompicRequest: Codable, Equatable {
    public var url: String
     
    public var iconFormat: NVMCompic.ImageType?
    public var iconResizeType: NVMCompic.ResizeType?
    public var iconWidth: Int?
    public var iconHeight: Int?
    
    public var backgroundFormat: NVMCompic.ImageType?
    public var backgroundResizeType: NVMCompic.ResizeType?
    public var backgroundWidth: Int?
    public var backgroundHeight: Int?
    
    public var cardFormat: NVMCompic.ImageType?
    public var cardResizeType: NVMCompic.ResizeType?
    public var cardWidth: Int?
    public var cardHeight: Int?
    
    public var nvmSecret: String?
    
    public init(url: String,
                
                iconFormat: NVMCompic.ImageType? = nil,
                iconResizeType: NVMCompic.ResizeType? = nil,
                iconWidth: Int? = nil,
                iconHeight: Int? = nil,
                
                backgroundFormat: NVMCompic.ImageType? = nil,
                backgroundResizeType: NVMCompic.ResizeType? = nil,
                backgroundWidth: Int? = nil,
                backgroundHeight: Int? = nil,
                
                cardFormat: NVMCompic.ImageType? = nil,
                cardResizeType: NVMCompic.ResizeType? = nil,
                cardWidth: Int? = nil,
                cardHeight: Int? = nil) {
        self.url = url
        
        self.iconFormat = iconFormat
        self.iconResizeType = iconResizeType
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
        
        self.backgroundFormat = backgroundFormat
        self.backgroundResizeType = backgroundResizeType
        self.backgroundWidth = backgroundWidth
        self.backgroundHeight = backgroundHeight
        
        self.cardFormat = cardFormat
        self.cardResizeType = cardResizeType
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
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
