//
//  UdacityResponse.swift
//  On The Map
//
//  Created by Hoang on 10.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import Foundation

struct UdacityResponse: Codable {
    let account: Account
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct ErrorResponse: Codable {
    let status: Int
    let error: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
