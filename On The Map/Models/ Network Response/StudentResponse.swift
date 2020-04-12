//
//  Student.swift
//  On The Map
//
//  Created by Hoang on 10.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import Foundation

struct StudentResponse: Codable {
    let nickname: String
}

struct PostingStudentResponse: Codable {
    let objectId: String
}

struct PuttingStudentResponse: Codable {
    let updatedAt: String
}
