//
//  LocationManager.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/30/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation
import CoreLocation

extension Coordinate {
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}

enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
}

protocol LocationPermissionsDelegate: class {
    func authorizationSucceeded()
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus)
}

protocol LocationManagerDelegate: class {
    func obtainedCoordinate(_ coordinate: Coordinate)
    func failedWithError(_ error: LocationError)
}

// Class will:
// 1. Request permissions to get location updates from the user
// 2. Starting Location Service
// 3. Informing us when a location fix has been obtained

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var permissionsDelegate: LocationPermissionsDelegate?
    weak var delegate: LocationManagerDelegate?
    
    init(delegate: LocationManagerDelegate?, permissionsDelegate: LocationPermissionsDelegate?) {
        self.delegate = delegate
        self.permissionsDelegate = permissionsDelegate
        super.init()
        manager.delegate = self
    }
    
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: return true
        default: return false
        }
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
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            permissionsDelegate?.authorizationSucceeded()
        } else {
            permissionsDelegate?.authorizationFailedWithStatus(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            delegate?.failedWithError(.unknownError)
            return
        }
        
        switch error.code {
        case .locationUnknown, .network: delegate?.failedWithError(.unableToFindLocation)
        case .denied: delegate?.failedWithError(.disallowedByUser)
        default: return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.failedWithError(.unableToFindLocation)
            return
        }
        
        let coordinate = Coordinate(location: location)
        
        delegate?.obtainedCoordinate(coordinate)
    }
}
