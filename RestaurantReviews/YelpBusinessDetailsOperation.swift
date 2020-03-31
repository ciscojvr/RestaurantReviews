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
        
        client.updateWithHoursAndPhotos(self.business) { [unowned self] result in // the client is owned by the operation, and we're going to reference self inside the closure. So we need to be aware of memory implications in here. We know that the operation queue we add this operation to is going to hold onto the operation until it is complete, which means, the client is going to exist as well, so we will capture self as an unowned reference.
            switch result {
            case .success(_): // we're updathing the business model so we don't want to extract it out of the associated value and do anything with it so we'll discard that.
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
