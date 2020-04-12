//
//  UdacityRequest.swift
//  On The Map
//
//  Created by Hoang on 10.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import Foundation

struct UdacityRequest: Codable {
    let udacity: Udacity
}

struct Udacity: Codable {
    let username: String
    let password: String
}
