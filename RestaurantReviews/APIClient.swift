//
//  APIClient.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/30/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation

protocol APIClient {
    // every APIClient must have a session object. With this session we can create data tasks that fetch JSON from a given URL.
    var session: URLSession { get }
}

enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        }
    }
}

extension APIClient {
    typealias JSON = [String: AnyObject]
    typealias JSONTaskCompletionHandler = (JSON?, APIError?) -> Void
    
    // any object that conforms to the APIClient protocol can use this function below, this default implementation, to create a data task that calls back with JSON data.
    func jsonTask(with request: URLRequest, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            // begins body of the callback
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        completion(json, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
}