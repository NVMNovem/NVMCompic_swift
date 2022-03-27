//
//  CompicError.swift
//  
//
//  Created by Damian Van de Kauter on 15/03/2022.
//

import Foundation

enum NVMCompicError: Error {
    case notInitialized
}

extension NVMCompicError: LocalizedError {
    var errorCode: Int {
        switch self {
        case .notInitialized:
            return 1001001
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return NSLocalizedString(
                "NVMCompic is not initialized.",
                comment: ""
            )
        }
    }
}
