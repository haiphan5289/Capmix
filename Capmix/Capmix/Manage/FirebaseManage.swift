//
//  FirebaseManage.swift
//  Charging
//
//  Created by haiphan on 04/08/2021.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

class FirebaseManage {
    static var share = FirebaseManage()
    private init() {
        
    }
    
    func activateDebugMode() {
      let settings = RemoteConfigSettings()
      // WARNING: Don't actually do this in production!
      settings.minimumFetchInterval = 0
      RemoteConfig.remoteConfig().configSettings = settings
    }
    
    func fetchCloudValues(completion: @escaping((Bool) -> Void) ) {
      // 1
      activateDebugMode()

      // 2
      RemoteConfig.remoteConfig().fetch { [weak self] _, error in
        if let error = error {
          print("Uh-oh. Got an error fetching remote values \(error)")
          // In a real app, you would probably want to call the loading
          // done callback anyway, and just proceed with the default values.
          // I won't do that here, so we can call attention
          // to the fact that Remote Config isn't loading.
            completion(false)
          return
        }

        // 3
        RemoteConfig.remoteConfig().activate { _, _ in
            let appPrimaryColorString = RemoteConfig.remoteConfig()
              .configValue(forKey: "isPrenium")
              .boolValue
            completion(appPrimaryColorString)
        }
      }
    }
    
    func loadDefaultValues() {
      let appDefaults: [String: Any?] = [
        "isPrenium": false
      ]
      RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
}
