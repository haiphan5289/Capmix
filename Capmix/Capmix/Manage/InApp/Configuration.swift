//
//  Configuration.swift
//  Drama_iOS
//
//  Created by Nguyễn Hải Âu on 4/3/21.
//  Copyright © 2021 ThanhPham. All rights reserved.
//

import Foundation
import KeychainSwift

class Configuration {
    static func setIcloudSync(isEnable: Bool) {
        KeychainSwift().set(isEnable, forKey: KeychainKeys.iclouldSync.rawValue)
    }
    
    static func getIclouldSyncStatus() -> Bool {
        return KeychainSwift().getBool(KeychainKeys.iclouldSync.rawValue) ?? false
    }
    
    static func setDropboxSync(isEnable: Bool) {
        KeychainSwift().set(isEnable, forKey: KeychainKeys.dropboxSync.rawValue)
    }
    
    static func getDropboxSyncStatus() -> Bool {
        return KeychainSwift().getBool(KeychainKeys.dropboxSync.rawValue) ?? false
    }
    
    static func joinPremiumUser(join: Bool) {
        KeychainSwift().set(join, forKey: KeychainKeys.userInPremium.rawValue)
    }
    
    static func inPremiumUser() -> Bool {
        return KeychainSwift().getBool(KeychainKeys.userInPremium.rawValue) ?? false
    }
    
    static func joinDiamondUser(join: Bool) {
        KeychainSwift().set(join, forKey: KeychainKeys.userInDiamond.rawValue)
    }
    
    static func inDiamondUser() -> Bool {
        return KeychainSwift().getBool(KeychainKeys.userInDiamond.rawValue) ?? false
    }
    
    static func resetData() {
        for key in KeychainKeys.allCases {
            KeychainSwift().delete(key.rawValue)
        }
    }
}

private enum KeychainKeys: String, CaseIterable {
    case iclouldSync = "iclouldSync"
    case dropboxSync = "dropboxSync"
    case userInPremium = "userInPremium"
    case userInDiamond = "userInDiamon"
}
