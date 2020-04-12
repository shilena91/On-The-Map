//
//  LocationClient.swift
//  On The Map
//
//  Created by Hoang on 9.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import Foundation
import MapKit

class LocationClient {
    
    static var objectId: String?
    
    enum Endpoints {
        static let baseURL = "https://onthemap-api.udacity.com/v1/StudentLocation"
        
        case getting
        case posting
        case putting
        
        var stringValue: String {
            switch self {
            case .getting:
                return Endpoints.baseURL + "?limit=100&order=-updatedAt"
            case .posting:
                return Endpoints.baseURL
            case .putting:
                return Endpoints.baseURL + "/\(objectId!)"
                
            }
        }
    }
    
    //MARK: - GETTING Student Locations
    
    class func getStudentLocations(completionHandler: @escaping ([Results], Error?) -> Void)  {
        
        let url = URL(string: LocationClient.Endpoints.getting.stringValue)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
                return
            }
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let safeData = try decoder.decode(StudenInformation.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(safeData.results, nil)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completionHandler([], error)
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK: - POST and PUTTING Student Location
    
    class func postingStudentLocation(firstName: String, lastName: String, mediaURL: String, coordinates: CLLocationCoordinate2D, completionHandler: @escaping (Bool, Error?) -> Void) {
        
        let body = Results(uniqueKey: "", firstName: firstName, lastName: lastName, longitude: coordinates.longitude, latitude: coordinates.latitude, mediaURL: mediaURL, mapString: "")
        
        taskForPostOrPutRequest(urlString: LocationClient.Endpoints.posting.stringValue, method: "POST", responseType: PostingStudentResponse.self, body: body) { (response, error) in
            if let safeData = response {
                objectId = safeData.objectId
                completionHandler(true, nil)
            }
            else {
                completionHandler(false, error)
            }
        }
    }
            
    class func puttingStudentLocation(firstName: String, lastName: String, mediaURL: String, coordinates: CLLocationCoordinate2D, completionHandler: @escaping (Bool, Error?) -> Void) {
        
        let body = Results(uniqueKey: "", firstName: firstName, lastName: lastName, longitude: coordinates.longitude, latitude: coordinates.latitude, mediaURL: mediaURL, mapString: "")
        
        taskForPostOrPutRequest(urlString: LocationClient.Endpoints.putting.stringValue, method: "PUT", responseType: PuttingStudentResponse.self, body: body) { (response, error) in
            if error != nil {
                completionHandler(false, error)
            }
            else {
                completionHandler(true, nil)
            }
        }
    }
    
    //MARK: - Helping functions
    
    class func taskForPostOrPutRequest<RequestType: Encodable, ResponseType: Decodable>(urlString: String, method: String, responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?) -> Void) {

        var request = URLRequest(url:URL(string: urlString)!)

        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil {
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
            return
          }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data!)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            }
            catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data!)
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }

        }
        task.resume()
    }
    
}
