//
//  Vendor.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation

public struct Vendor: Codable {

    let name: String
    let state: String?
    let country: String?
    let isCapital: Bool?
    let population: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case isCapital = "capital"
        case population
    }

}
