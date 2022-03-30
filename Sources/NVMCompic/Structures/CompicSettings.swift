//
//  CompicSettings.swift
//  
//
//  Created by Damian Van de Kauter on 30/03/2022.
//

import Foundation

public struct CompicSettings {
    
    /**
     Set this to a path where local compics may be stored.
     */
    public var compicPath: URL
    
    /**
     Set this option if you want to remove unused compics after a specific amount of time.
     */
    public var clearUnusedCompics: After
    
    
    public init(compicPath: URL,
                clearUnusedCompics: After = .never) {
        self.compicPath = compicPath
        self.clearUnusedCompics = clearUnusedCompics
    }
    
    
    public enum After {
        
        /**
         Use this to indicate that stored compics may never be deleted on the device.
         */
        case never
        
        /**
         Use this to indicate that stored compics may be deleted after a week on the device.
         */
        case week
        
        /**
         Use this to indicate that stored compics may be deleted after a month on the device.
         */
        case month
        
        /**
         Use this to indicate that stored compics may be deleted after a year on the device.
         */
        case year
    }
}
