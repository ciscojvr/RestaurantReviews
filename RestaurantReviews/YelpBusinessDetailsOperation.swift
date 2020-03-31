//
//  YelpBusinessDetailsOperation.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/31/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation

// Objective of this Operation: To fetch the details for a given business, update that instance and notify us when the operation is completed.
class YelpBusinessDetailsOperation: Operation {
    let business: YelpBusiness
    let client: YelpClient
    
    init(business: YelpBusiness, client: YelpClient) {
        self.business = business
        self.client = client
        super.init()
    }
}
