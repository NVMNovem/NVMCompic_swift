//
//  CompicError.swift
//  
//
//  Created by Damian Van de Kauter on 15/03/2022.
//

import Foundation

enum NVMCompicError: Error {
    case serviceUnavailable
    case notInitialized
    case invalidObject
    case invalidUrl
}

extension NVMCompicError: LocalizedError {
    var errorCode: Int {
        switch self {
        case .serviceUnavailable:
            return 1001000
        case .notInitialized:
            return 1001001
        case .invalidObject:
            return 1001002
        case .invalidUrl:
            return 1001003
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            return NSLocalizedString(
                "NVMCompic is unavailabe.",
                comment: ""
            )
        case .notInitialized:
            return NSLocalizedString(
                "NVMCompic is not initialized.",
                comment: ""
            )
        case .invalidObject:
            return NSLocalizedString(
                "Object is invalid.",
                comment: ""
            )
        case .invalidUrl:
            return NSLocalizedString(
                "Url is invalid.",
                comment: ""
            )
        }
    }
}
