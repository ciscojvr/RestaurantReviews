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
    
    private var _finished = false // this is called a backing property since it serves as the underlying storage for a public property. _finished is an Objective-C convention, were private backing instance variables were prefized with an underscore to disambiguate between the backing variable and the public one.
    
    override private(set) var isFinished: Bool { // private(set) makes the setter private
        get {
            return _finished
        }
        
        set {
           _finished = newValue // newValue is whatever new value we set to isFinished
        }
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
    }
}
