//
//  RealmModel.swift
//  KFC
//
//  Created by Dong Nguyen on 12/12/19.
//  Copyright © 2019 TVT25. All rights reserved.
//

import Foundation
import RealmSwift

class ProjectRealm: Object {
    @objc dynamic var data: Data?
    dynamic var url: URL = URL(fileURLWithPath: "")

    init(model: ProjectModel) {
        super.init()
        do {
            self.data = try model.toData()
            self.url = model.url
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    required init() {
        super.init()
    }
}

struct ProjectModel: Codable {
    let url: URL
    let count: Double
}
