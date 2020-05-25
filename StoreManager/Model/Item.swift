//
//  Product.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import Firebase

//Khai báo stuct Item sử dụng Codable để encode và decode, tức là có thể hỗ trợ format JSON (một cách tiện lợi khi tương tác object và JSON)
public struct Item: Codable {
    var name: String
    var price: Int
    var description: String?
    var imageUrl: String?
    var id: String?
    var vendors: [String] = []
    var count: Int?
    let userId: String? = Auth.auth().currentUser?.uid
}
