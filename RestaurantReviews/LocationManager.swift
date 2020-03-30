//
//  LocationManager.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/30/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
}

protocol LocationPermissionsDelegate: class {
    func authorizationSucceeded()
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus)
}

// Class will:
// 1. Request permissions to get location updates from the user
// 2. Starting Location Service
// 3. Informing us when a location fix has been obtained

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var permissionsDelegate: LocationPermissionsDelegate?
    
    init(permissionsDelegate: LocationPermissionsDelegate?) {
        self.permissionsDelegate = permissionsDelegate
        super.init()
        manager.delegate = self
    }
    
    func requestLocationAuthorization() throws {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .restricted || authorizationStatus == .denied {
            throw LocationError.disallowedByUser
        } else if authorizationStatus == .notDetermined { // if we've never asked for permission before
            manager.requestWhenInUseAuthorization()
        } else { // if we've obtained authorization before and we're still requesting for it
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            permissionsDelegate?.authorizationSucceeded()
        } else {
            permissionsDelegate?.authorizationFailedWithStatus(status)
        }
    }
}
