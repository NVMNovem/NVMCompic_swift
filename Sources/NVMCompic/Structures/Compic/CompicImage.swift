//
//  CompicImage.swift
//  
//
//  Created by Damian Van de Kauter on 04/04/2022.
//

import Foundation

public struct CompicImage: Codable {
    public var type: ImageType
    public var data: Data
    public var compicRequest: CompicRequest
    public var format: NVMCompic.ImageType?
    public var resizeType: NVMCompic.ResizeType?
    public var width: Int?
    public var height: Int?
    
    public enum ImageType: String, Codable {
        case icon
        case background
        case card
    }
}


