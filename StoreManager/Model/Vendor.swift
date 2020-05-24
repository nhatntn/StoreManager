//
//  Vendor.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import Firebase

public struct Vendor: Codable {
    var name: String
    var address: String?
    var email: String?
    var phone: String?
    var imageUrl: String?
    var id: String?
    let userId: String? = Auth.auth().currentUser?.uid
    var products: [Item]
}
