//
//  User.swift
//  StoreManager
//
//  Created by nhatnt on 5/11/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation

public struct User: Codable {
    let id: String?
    let name: String?
    let email: String?
    let outOfStock: Int
    let nearOutOfStock: Int
    let language: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case outOfStock
        case nearOutOfStock
        case language
    }

    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.outOfStock = dictionary["outOfStock"] as? Int ?? 5
        self.nearOutOfStock = dictionary["nearOutOfStock"] as? Int ?? 10
        self.language = dictionary["language"] as? String ??  "English"
    }
}
