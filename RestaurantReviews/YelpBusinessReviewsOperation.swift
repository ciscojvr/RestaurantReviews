//
//  YelpBusinessReviewsOperation.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/31/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation

class YelpBusinessReviewsOperation: Operation {
    let business: YelpBusiness
    let client: YelpClient
    
    init(business: YelpBusiness, client: YelpClient) {
        self.business = business
        self.client = client
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _finished = false // this is called a backing property since it serves as the underlying storage for a public property. _finished is an Objective-C convention, were private backing instance variables were prefized with an underscore to disambiguate between the backing variable and the public one.
    
    override private(set) var isFinished: Bool { // private(set) makes the setter private
        get {
            return _finished
        }
        
        set {
            willChangeValue(forKey: "isFinished")
           _finished = newValue // newValue is whatever new value we set to isFinished
            didChangeValue(forKey: "isFinished")
            // before and after the value of isFinished changes, we'll notifiy any observers and they can call the getter accordingly.
        }
    }
    
    private var _executing = false
    
    override private(set) var isExecuting: Bool {
        get {
            return _executing
        }
        
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        client.reviews(for: business) { [unowned self] result in
            switch result {
            case .success(let reviews):
                self.business.reviews = reviews
                self.isExecuting = false
                self.isFinished = true
            case .failure(let error):
                print(error)
                self.isExecuting = false
                self.isFinished = true
            }
        }
    }
}
