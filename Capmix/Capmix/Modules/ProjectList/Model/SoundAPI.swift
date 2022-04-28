//
//  SoundAPI.swift
//  Capmix
//
//  Created by haiphan on 28/04/2022.
//

import Foundation

struct ListSound: Codable {
    let list: [SoundModel]?
    enum CodingKeys: String, CodingKey {
        case list
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        list = try values.decodeIfPresent([SoundModel].self, forKey: .list)
    }
}

// MARK: - Datum
struct SoundModel: Codable {
    let id: Int?
    let filename: String?
    let name: String?
    let createDate, writeDate: Int?

    enum CodingKeys: String, CodingKey {
        case id, filename, name
//        case artist
        case createDate = "create_date"
        case writeDate = "write_date"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        filename = try values.decodeIfPresent(String.self, forKey: .filename)
        createDate = try values.decodeIfPresent(Int.self, forKey: .createDate)
        writeDate = try values.decodeIfPresent(Int.self, forKey: .writeDate)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}
