//
//  YelpClient.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/31/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation

class YelpClient: APIClient {
    let session: URLSession
    private let token: String
    
    init(configuration: URLSessionConfiguration, oauthToken: String) {
        self.session = URLSession(configuration: configuration)
        self.token = oauthToken
    }
    
    convenience init(oauthToken: String) {
        self.init(configuration: .default, oauthToken: oauthToken)
    }
    
    // since search is not a generic method, we can finally specify concrete types for Result in our completion handler below.
    func search(withTerm term: String, at coordinate: Coordinate, categories: [YelpCategory] = [], radius: Int? = nil, limit: Int = 50, sortBy sortType: Yelp.YelpSortType = .rating, completion: @escaping (Result<[YelpBusiness], APIError>) -> Void) {
        
        let endpoint = Yelp.search(term: term, coordinate: coordinate, radius: radius, categories: categories, limit: limit, sortBy: sortType)
        
        let request = endpoint.requestWithAuthorizationHeader(oauthToken: token)
        
        fetch(with: request, parse: { json -> [YelpBusiness] in
            guard let businesses = json["businesses"] as? [[String: Any]] else { return [] }
            
            return businesses.compactMap { YelpBusiness(json: $0) }
            
        }, completion: completion)
    }
}
