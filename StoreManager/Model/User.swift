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
    let outOfStock: Int?
    let nearOutOfStock: Int?
    let language: String?
}
