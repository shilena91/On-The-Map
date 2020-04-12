//
//  StudenLocation.swift
//  On The Map
//
//  Created by Hoang on 9.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import Foundation
import MapKit

struct StudenInformation: Codable {
    let results: [Results]
}

struct Results: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mediaURL: String
    let mapString: String
}

class Student: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(name: String, coordinate: CLLocationCoordinate2D, mediaURL: String) {
        self.title = name
        self.coordinate = coordinate
        self.subtitle = mediaURL
    }
}
