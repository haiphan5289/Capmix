//
//  UIFont+Extension.swift
//  Dayshee
//
//  Created by paxcreation on 5/21/21.
//  Copyright © 2021 ThanhPham. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    @objc var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
    }
}

extension UITextField {

    @objc var substituteFontName : String {
        get { return self.font?.fontName ?? "" }
        set { self.font = UIFont(name: newValue, size: self.font?.pointSize ?? 14) }
    }

}

extension UITextView {

    @objc var substituteFontName : String {
        get { return self.font?.fontName ?? "" }
        set { self.font = UIFont(name: newValue, size: self.font?.pointSize ?? 14) }
    }

}

struct AppFontName {
    static let regular = SettingDefaultFont.DEFAULT_NAME_FONT
    static let bold = SettingDefaultFont.DEFAULT_NAME_BOLD
    static let semibold = SettingDefaultFont.DEFAULT_NAME_SEMIBOLD
    static let italic = SettingDefaultFont.DEFAULT_NAME_BOLD
    static let medium = SettingDefaultFont.DEFAULT_NAME_MEDIUM
    static let heavy = SettingDefaultFont.DEFAULT_NAME_BOLD
    static let black = SettingDefaultFont.DEFAULT_NAME_BOLD
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    static var isOverrided: Bool = false

    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }

    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func mySemiBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.semibold, size: size)!
    }

    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc class func myMediumSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.medium, size: size)!
    }
    
    @objc class func myHeavySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.heavy, size: size)!
    }
    
    @objc class func myBlackSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.black, size: size)!
    }

    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        var fontName = ""
        switch fontAttribute {
        
        case "CTFontRegularUsage":
            fontName = AppFontName.regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFontName.bold
        case "CTFontDemiUsage", "CTFontSemiboldUsage":
            fontName = AppFontName.semibold
        case "CTFontMediumUsage":
            fontName = AppFontName.medium
        case "CTFontHeavyUsage":
            fontName = AppFontName.heavy
        case "CTFontBlackUsage":
            fontName = AppFontName.black
        case "CTFontObliqueUsage":
            fontName = AppFontName.italic
        default:
            fontName = AppFontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }

    class func overrideInitialize() {
        guard self == UIFont.self, !isOverrided else { return }

        // Avoid method swizzling run twice and revert to original initialize function
        isOverrided = true

        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }

        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }

//        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
//            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
//            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
//        }

        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}
