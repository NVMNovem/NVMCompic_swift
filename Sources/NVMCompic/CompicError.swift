//
//  CompicError.swift
//  
//
//  Created by Damian Van de Kauter on 15/03/2022.
//

import Foundation

enum NVMCompicError: Error {
    case notInitialized
    case invalidObject
}

extension NVMCompicError: LocalizedError {
    var errorCode: Int {
        switch self {
        case .notInitialized:
            return 1001001
        case .invalidObject:
            return 1001002
        }
    }
    
    var errorDescription: String? {
        switch self {
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
        }
    }
}
