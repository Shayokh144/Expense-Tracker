//
//  HomeViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 13/11/23.
//

import Combine
import CoreLocation
import Foundation

final class HomeViewModel: NSObject, ObservableObject {

    var authorizationStatus: CLAuthorizationStatus
    private let locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        print("init status: \(authorizationStatus.rawValue)")
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func viewDidAppear() {
        // Create  a user default to check if first time app launched then call
        //locationManager.requestWhenInUseAuthorization()
    }
}

// CoreLocation
extension HomeViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("initnext status: \(authorizationStatus.rawValue)")
        /*if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedWhenInUse {

        }*/
    }
}
