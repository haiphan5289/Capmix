//
//  RealmModel.swift
//  iKanBid
//
//  Created by Quân on 7/23/19.
//  Copyright © 2019 TVT25. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class RealmManager {
    
    struct Constant {
        static let minimum: Int = 3
    }
    
    static var shared = RealmManager()
    var realm : Realm!
    
    init() {
        migrateWithCompletion()
        realm = try! Realm()
    }
    
    func migrateWithCompletion() {
        let config = RLMRealmConfiguration.default()
        config.schemaVersion = 7
        
        config.migrationBlock = { (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        RLMRealmConfiguration.setDefault(config)
        print("schemaVersion after migration:\(RLMRealmConfiguration.default().schemaVersion)")
        RLMRealm.default()
    }
    
    func getProjectRealm() -> [ProjectRealm]  {
        let arr = realm.objects(ProjectRealm.self).toArray(ofType: ProjectRealm.self)
        return arr
    }

    func updateOrInsertProject(model: ProjectModel) {
        let list = self.getProjectRealm()

        if let index = list.firstIndex(where: { $0.url == model.url  }) {
            try! realm.write {
                list[index].data = try? model.toData()
                list[index].url = model.url
                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.addedProject.rawValue), object: nil, userInfo: nil)
            }
        } else {
            let itemAdd = ProjectRealm.init(model: model)
            try! realm.write {
                realm.add(itemAdd)
                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.addedProject.rawValue), object: nil, userInfo: nil)
            }
        }
    }
//    
//    func deleteLastRecording() {
//        let items = self.getAllRecodingHomeRealm()
//        if let last = items.last {
//            try! realm.write {
//                realm.delete(last)
//                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecording.rawValue), object: last, userInfo: nil)
//            }
//        }
//    }
//    
//    func deleteRecording(listRecord: [RecordingHomeModel] ) {
//        let items = self.getAllRecodingHomeRealm()
//        
//        listRecord.forEach { record in
//            if let index = items.firstIndex(where: {$0.id == record.id}) {
//                try! realm.write {
//                    realm.delete(items[index])
//                    NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecording.rawValue), object: items[index], userInfo: nil)
//                }
//            }
//        }
//    }
//    
//    func addNewFolder() {
//        let newFolder = RecordingHomeModel(imageData: Asset.icNewfolder.image.pngData(), title: "", id: Date().convertDateToLocalTime().timeIntervalSince1970)
//        self.updateOrInsertConfig(model: newFolder)
//    }
//    
//    func deleteRecordingAll() {
//        let items = self.getAllRecodingHomeRealm()
//        try! realm.write {
//            realm.delete(items)
//            NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecording.rawValue), object: nil, userInfo: nil)
//        }
//    }
//
    func getProjects() -> [ProjectModel] {
        let listRealm = self.getProjectRealm()
        var list: [ProjectModel] = []
        
        listRealm.forEach { model in
            guard let model = model.data?.toCodableObject() as ProjectModel? else {
                return
            }
            list.append(model)
        }
        
        return list
    }
//    
//    private func getAllRecordAudioRealm() -> [RecordAudioRealm]  {
//        let arr = realm.objects(RecordAudioRealm.self).toArray(ofType: RecordAudioRealm.self)
//        return arr
//    }
//
//    func updateOrInsertAudioRecord(model: RecordAudioModel) {
//        let list = self.getAllRecordAudioRealm()
//
//        if let index = list.firstIndex(where: { $0.id == model.id  }) {
//            try! realm.write {
//                list[index].data = try? model.toData()
//                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecordAudio.rawValue), object: model, userInfo: nil)
//            }
//        } else {
//            let itemAdd = RecordAudioRealm.init(model)
//            try! realm.write {
//                realm.add(itemAdd)
//                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecordAudio.rawValue), object: model, userInfo: nil)
//            }
//        }
//    }
//
//    func getListRecordAudio() -> [RecordAudioModel] {
//        let listRealm = self.getAllRecordAudioRealm()
//        var list: [RecordAudioModel] = []
//        
//        listRealm.forEach { model in
//            guard let model = model.data?.toCodableObject() as RecordAudioModel? else {
//                return
//            }
//            list.append(model)
//        }
//        
//        return list
//    }
//    
//    private func getRecordSearchRealm() -> [RecordAudioSearchRealm]  {
//        let arr = realm.objects(RecordAudioSearchRealm.self).toArray(ofType: RecordAudioSearchRealm.self)
//        return arr
//    }
//    
//    func updateOrInsertAudioRecordSearch(model: RecordAudioModel) {
//        let list = self.getRecordSearchRealm()
//
//        if list.firstIndex(where: { $0.id == model.id  }) == nil {
//            let itemAdd = RecordAudioSearchRealm.init(model)
//            try! realm.write {
//                realm.add(itemAdd)
//                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecordAudioSearch.rawValue), object: model, userInfo: nil)
//            }
//        }
//    }
//    
//    func getListRecordAudioSearch() -> [RecordAudioModel] {
//        let listRealm = self.getRecordSearchRealm()
//        var list: [RecordAudioModel] = []
//        
//        listRealm.forEach { model in
//            guard let model = model.data?.toCodableObject() as RecordAudioModel? else {
//                return
//            }
//            list.append(model)
//        }
//        
//        return list
//    }
//    
//    func deleteRecordingSearchAll() {
//        let items = self.getRecordSearchRealm()
//        try! realm.write {
//            realm.delete(items)
//            NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecordAudioSearch.rawValue), object: nil, userInfo: nil)
//        }
//    }
//    
//    
//    
//    private func createValueDefault() {
//        let itemAll = RecordingHomeModelRealm.init(RecordingHomeModel.itemAll)
//        let itemStart = RecordingHomeModelRealm.init(RecordingHomeModel.itemStarted)
//        let itemTrash = RecordingHomeModelRealm.init(RecordingHomeModel.itemTrash)
//        try! realm.write {
//            realm.add(itemAll)
//            realm.add(itemStart)
//            realm.add(itemTrash)
//            NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didRecording.rawValue), object: nil, userInfo: nil)
//        }
//    }
    
    
    
}


extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}


extension Object {
    func toDictionary() -> [String:Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dicProps = [String:Any]()
        for (key, value) in self.dictionaryWithValues(forKeys: properties) {
            if let value = value as? ListBase {
                dicProps[key] = value.toArray()
            } else if let value = value as? Object {
                dicProps[key] = value.toDictionary()
            } else {
                dicProps[key] = value
            }
        }
        return dicProps
    }
}

extension ListBase {
    func toArray() -> [Any] {
        var _toArray = [Any]()
        for i in 0..<self._rlmArray.count {
            if let value = self._rlmArray[i] as? Object {
                let obj = unsafeBitCast(self._rlmArray[i], to: Object.self)
                _toArray.append(obj.toDictionary())
            } else {
                _toArray.append(self._rlmArray[i])
            }
            
        }
        return _toArray
    }
}

extension Data {
    func toCodableObject<T: Codable>() -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        if let obj = try? decoder.decode(T.self, from: self) {
            return obj
        }
        return nil    }
    
}
