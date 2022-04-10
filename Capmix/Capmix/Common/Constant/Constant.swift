//
//  Constant.swift
//  CameraMakeUp
//
//  Created by haiphan on 22/09/2021.
//

import Foundation
import UIKit

final class ConstantApp {
    static var shared = ConstantApp()
    
    private init() {}
    
    let fileRealm: String = "default.realm.lock"
    let fileRealmManage: String = "default.realm.management"
    let fileRealmNote: String = "default.realm.note"
    let fileRealmDefault: String = "default.realm"
    let server: String = ""
    let convertFolder: String = "Convert"
    let backupiCloud: String = "backupiCloud"
    let radiusImageCell: Int = 10
    let folderPhotos: String = "Photos"
    let folderVideos: String = "Videos"
    let folderMusics: String = "Music"
    let folderDocuments: String = "Documents"
    let folderTrashs: String = "Trashs"
    let SHARE_APPLICATION_DELEGATE = UIApplication.shared.delegate as! AppDelegate
    let linkTerm: String = "https://sites.google.com/view/filza-file-manager-document/terms-and-condition?authuser=0"
    let linkSUpport: String = "https://sites.google.com/view/filza-file-manager-document/support?authuser=0"
    let linkPrivacy: String = "https://sites.google.com/view/filza-file-manager-document/privacy-policy?authuser=0"

    func getHeightSafeArea(type: GetHeightSafeArea.SafeAreaType) -> CGFloat {
        return GetHeightSafeArea.shared.getHeight(type: type)
    }
    
}
