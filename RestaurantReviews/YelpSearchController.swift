//
//  YelpSearchController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit
import MapKit

class YelpSearchController: UIViewController {
    
    // MARK: - Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    let dataSource = YelpSearchResultsDataSource()
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    lazy var client: YelpClient = { // When initializing YelpClient, we need an OAuth token here. We're making this a lazy stored property with a closure, so that inside the closure we can load our token from the key chain and use it.
        let yelpAccount = YelpAccount.loadFromKeychain()
        let oauthToken = yelpAccount!.accessToken
        
        return YelpClient(oauthToken: oauthToken)
    }()
    
    var coordinate: Coordinate? {
        didSet {
            if let coordinate = coordinate {
                showNearbyRestaurants(at: coordinate)
            }
        }
    } // we have to make this property optional otherwise we have to deal with UIViewController's initialization rules.
    
    let queue = OperationQueue()
    
    var isAuthorized: Bool {
        let isAuthorizedWithYelpToken = YelpAccount.isAuthorized
        let isAuthorizedForLocation = LocationManager.isAuthorized
        
        return isAuthorizedWithYelpToken && isAuthorizedForLocation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    // MARK: - Table View
    func setupTableView() {
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
    }
    
    func showNearbyRestaurants(at coordinate: Coordinate) {
        client.search(withTerm: "", at: coordinate) { [weak self] result in
            switch result {
            case .success(let businesses):
                self?.dataSource.update(with: businesses)
                self?.tableView.reloadData()
                
                let annotations: [MKPointAnnotation] = businesses.map { business in
                    let point = MKPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: business.location.latitude, longitude: business.location.longitude)
                    
                    point.title = business.name
                    point.subtitle = business.isClosed ? "Closed" : "Open"
                    return point
                }
                
                self?.mapView.addAnnotations(annotations)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: - Search
    
    func setupSearchBar() {
        self.navigationItem.titleView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    
    // MARK: - Permissions
    
    /// Checks (1) if the user is authenticated against the Yelp API and has an OAuth
    /// token and (2) if the user has authorized location access for whenInUse tracking.
    func checkPermissions() {
        let isAuthorizedWithToken = YelpAccount.isAuthorized
        let isAuthroizedForLocation = LocationManager.isAuthorized
        
        let permissionsController = PermissionsController(isAuthorizedForLocation: isAuthroizedForLocation, isAuthorizedWithToken: isAuthorizedWithToken)
        present(permissionsController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension YelpSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let business = dataSource.object(at: indexPath)
        
        let detailsOperation = YelpBusinessDetailsOperation(business: business, client: self.client)
        
        let reviewsOperation = YelpBusinessReviewsOperation(business: business, client: client)
        
        // to ensure that the reviews operation only executes upon completion of the first one, we can make it a dependency of the first operation. We want the reviews operation to execute after the details operation is done, so we add the details operation as a dependency of the reviews operation.
        reviewsOperation.addDependency(detailsOperation)
        
        // by linking these dependencies we're ensuring that our queue is effectively a serial queue, executing one operation at once.
        
        reviewsOperation.completionBlock = {
            // since the operation will likely be executed on a backgroud thread, we'll make sure we execute this code on the main thread.
            DispatchQueue.main.async {
                self.dataSource.update(business, at: indexPath)
                
                // programmatically executing a segue and transitioning to the destination view controller.
                self.performSegue(withIdentifier: "showBusiness", sender: nil)
            }
        }
        queue.addOperation(detailsOperation)
        queue.addOperation(reviewsOperation)
    }
}

// MARK: - Search Results
extension YelpSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text, let coordinate = coordinate else { return }
        
        if !searchTerm.isEmpty {
            // because we are using a closure below that is going to be executed in the background thread. And we need to capture self to update the data model, we capture self weakly.
            client.search(withTerm: searchTerm, at: coordinate) { [weak self] result in
                switch result {
                case .success(let businesses):
                    self?.dataSource.update(with: businesses)
                    self?.tableView.reloadData()
                    
                    self?.mapView.removeAnnotations(self!.mapView.annotations) // at this point, we're calling removeAnnotations, we are assuming that we do have some so we just force unwrap self and grab the annotations from the exisiting map view
                    
                    let annotations: [MKPointAnnotation] = businesses.map { business in
                        let point = MKPointAnnotation()
                        point.coordinate = CLLocationCoordinate2D(latitude: business.location.latitude, longitude: business.location.longitude)
                        
                        point.title = business.name
                        point.subtitle = business.isClosed ? "Closed" : "Open"
                        return point
                    }
                    
                    self?.mapView.addAnnotations(annotations)
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

// MARK: - Navigation
extension YelpSearchController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusiness" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let business = dataSource.object(at: indexPath)
                let detailController = segue.destination as! YelpBusinessDetailController
                detailController.business = business
                detailController.dataSource.updateData(business.reviews)
            }
        }
    }
}

// MARK: - Location Manager Delegate

// Since the YelpSearchController is acting as the delegate to the LocationManager, we need to conform to the protocol and provide implementations for the required methods.
extension YelpSearchController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
//        print(coordinate)
        adjustMap(with: coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        print(error)
    }
}

// MARK: - MapKit
extension YelpSearchController {
    func adjustMap(with coordinate: Coordinate) {
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // the span value encapsulates the level of zoom we need for a given map, given our specific coordinates and the distance we want to show on the map.
        let span = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: 2500, longitudinalMeters: 2500).span
        
        let region = MKCoordinateRegion(center: coordinate2D, span: span)
        mapView.setRegion(region, animated: true)
    }
}


