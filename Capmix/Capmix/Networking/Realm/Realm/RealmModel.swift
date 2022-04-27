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
    @objc dynamic var url: URL?

    init(url: URL, model: Int) {
        super.init()
        self.url = url
        self.count = count
    }
    required init() {
        super.init()
    }
}

struct ProjectModel: Codable {
    let url: URL
    let count: Double
}
