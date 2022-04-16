//
//  CampixManage.swift
//  Capmix
//
//  Created by haiphan on 10/04/2022.
//

import Foundation
import EasyBaseAudio

final class CampixManage {
    static var shared = CampixManage()
    
    
    func createURL(folder: String, name: String, type: AudioType) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent("\(folder)/\(name)").appendingPathExtension("m4a")
        return outputURL
    }
}
