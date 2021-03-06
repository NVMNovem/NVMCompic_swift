//
//  CompicRequest.swift
//  
//
//  Created by Damian Van de Kauter on 30/03/2022.
//

import Foundation

public struct CompicRequest: Codable, Equatable, Identifiable {
    public var id: String { self.getIdentifier() }
    
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
    
    public var colors: Bool?
    
    public var nvmSecret: String?
    
    public static func ==(lhs: CompicRequest, rhs: CompicRequest) -> Bool {
        return lhs.getIdentifier() == rhs.getIdentifier()
    }
    
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
                
                colors: Bool? = nil,
                
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
        
        self.colors = colors
        
        self.nvmSecret = nvmSecret
    }
    
    internal func getIdentifier() -> String { //Only used for Equatable protocol
        var uniqueString = "url:" + self.url
        
        if let iconVar = self.icon { uniqueString += "icon:" + String(iconVar) }
        if let iconFormatVar = self.iconFormat { uniqueString += "iconFormat:" + iconFormatVar.rawValue }
        if let iconResizeTypeVar = self.iconResizeType { uniqueString += "iconResizeType:" + iconResizeTypeVar.rawValue }
        if let iconWidthVar = self.iconWidth { uniqueString += "iconWidth:" + String(iconWidthVar) }
        if let iconHeightVar = self.iconHeight { uniqueString += "iconHeight:" + String(iconHeightVar) }
        
        if let backgroundVar = self.background { uniqueString += "background:" + String(backgroundVar) }
        if let backgroundFormatVar = self.backgroundFormat { uniqueString += "backgroundFormat:" + backgroundFormatVar.rawValue }
        if let backgroundResizeTypeVar = self.backgroundResizeType { uniqueString += "backgroundResizeType:" + backgroundResizeTypeVar.rawValue }
        if let backgroundWidthVar = self.backgroundWidth { uniqueString += "backgroundWidth:" + String(backgroundWidthVar) }
        if let backgroundHeightVar = self.backgroundHeight { uniqueString += "backgroundHeight:" + String(backgroundHeightVar) }
        
        return uniqueString
    }
}
