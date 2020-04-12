//
//  Udacity.swift
//  On The Map
//
//  Created by Hoang on 10.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import Foundation

class UdacityClient {
        
    static var key: String = ""
    static var firstName: String = ""
    static var lastName: String = ""
    
    enum Endpoints {
        static let baseURL = "YOUR UDACITY URL"

        case session
        case publicUser
        
        var stringValue: String {
            switch self {
            case .session:
                return UdacityClient.Endpoints.baseURL + "session"
            case .publicUser:
                return UdacityClient.Endpoints.baseURL + "users/" + UdacityClient.key
            }
        }

    }
    

    class func postRequest(username: String, password: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: UdacityClient.Endpoints.session.stringValue)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        let body = UdacityRequest(udacity: Udacity(username: username, password: password))
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            let decoder = JSONDecoder()
            
            if let data = data {
                do {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range)
                    let responseObject = try decoder.decode(UdacityResponse.self, from: newData)
                    key = responseObject.account.key
                    DispatchQueue.main.async {
                        completionHandler(true, nil)
                    }
                }
                catch {
                    do {
                        let range = 5..<data.count
                        let newData = data.subdata(in: range)
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: newData)
                        DispatchQueue.main.async {
                            completionHandler(false, errorResponse)
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            completionHandler(false, error)
                            print(error)

                        }
                    }
                }
            }
        }
        task.resume()
    }

    
    class func getRequest() {
        
        let request = URLRequest(url: URL(string: UdacityClient.Endpoints.publicUser.stringValue)!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                return
            }
            let decoder = JSONDecoder()
            do {
                let range = 5..<data!.count
                let newData = data?.subdata(in: range)
                print(String(data: newData!, encoding: .utf8)!)
                let safeData = try decoder.decode(StudentResponse.self, from: newData!)
                let nickname = safeData.nickname.components(separatedBy: " ")
                firstName = nickname[0]
                lastName = nickname[1]
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    class func deletingSession() {
        
        var request = URLRequest(url: URL(string: UdacityClient.Endpoints.session.stringValue)!)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil { // Handle error…
              return
          }
          key = ""
        }
        task.resume()
    }
}
