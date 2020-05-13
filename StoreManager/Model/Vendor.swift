//
//  Vendor.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation

public struct Vendor: Codable {
    var name: String
    var address: String?
    var email: String?
    var phone: String?
    var imageUrl: String?
    var id: String?
    var products: [Item]
}
