//
//  AppSettings.swift
//  GooDic
//
//  Created by ttvu on 6/2/20.
//  Copyright © 2020 paxcreation. All rights reserved.
//

import Foundation

enum AppSettings {
    @Storage(key: "isFirstApp", defaultValue: true)
    static var isFirstApp: Bool
    
}
