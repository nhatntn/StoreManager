//
//  Product.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation

public struct Item: Codable {
    
    var name: String
    var price: Int
    var description: String?
    var imageUrl: String?
    var vendors: [String: Int]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case price
        case description
        case imageUrl
        case vendors
    }

}
