//
//  YelpSearchController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit

class YelpSearchController: UIViewController {
    
    // MARK: - Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = YelpSearchResultsDataSource()
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    var coordinate: Coordinate? // we have to make this property optional otherwise we have to deal with UIViewController's initialization rules.
    
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
    
}

// MARK: - Search Results
extension YelpSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text else { return }
        
        print("Search text: \(searchTerm)")
    }
}

// MARK: - Navigation
extension YelpSearchController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusiness" {
            
        }
    }
}

// MARK: - Location Manager Delegate

// Since the YelpSearchController is acting as the delegate to the LocationManager, we need to conform to the protocol and provide implementations for the required methods.
extension YelpSearchController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        print(coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        print(error)
    }
}

