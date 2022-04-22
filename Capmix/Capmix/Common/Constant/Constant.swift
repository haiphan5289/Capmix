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
    
    let server: String = ""
    let folderRecording: String = "Recording"
    let folderApple: String = "Apple"
    let folderConvert: String = "Covert"
//    let SHARE_APPLICATION_DELEGATE = UIApplication.shared.delegate as! AppDelegate
//    let linkTerm: String = "https://sites.google.com/view/filza-file-manager-document/terms-and-condition?authuser=0"
//    let linkSUpport: String = "https://sites.google.com/view/filza-file-manager-document/support?authuser=0"
//    let linkPrivacy: String = "https://sites.google.com/view/filza-file-manager-document/privacy-policy?authuser=0"

    func getHeightSafeArea(type: GetHeightSafeArea.SafeAreaType) -> CGFloat {
        return GetHeightSafeArea.shared.getHeight(type: type)
    }
    
}
