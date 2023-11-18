//
//  HomeViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 13/11/23.
//

import Combine
import CoreLocation
import Foundation
import MapKit

final class HomeViewModel: NSObject, ObservableObject {

    private var authorizationStatus: CLAuthorizationStatus
    private let locationManager: CLLocationManager
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlaceMark: CLPlacemark?
    @Published var addressString: String = ""

    private let userDefaultManager: UserDefaultsManagerProtocol

    init(
        userDefaultManager: UserDefaultsManagerProtocol = UserDefaultsManager(),
        locationManager: CLLocationManager = CLLocationManager()
    ) {
        self.userDefaultManager = userDefaultManager
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        print("init status: \(authorizationStatus.rawValue)")
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }


    func viewDidAppear() {
        if userDefaultManager.isFirstInstall() {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func getCurrentLocation() -> CLLocationCoordinate2D {
        guard let lastLocation = lastSeenLocation else {
            return CLLocationCoordinate2D(
                latitude: 13.73,
                longitude: 100.52
            )
        }
        print("CLLC: \(lastLocation.coordinate)")
        return lastLocation.coordinate
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }
}

// CoreLocation
extension HomeViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("initnext status: \(authorizationStatus.rawValue)")
//        if userDefaultManager.isFirstInstall() && authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedWhenInUse {
//            // TODO: SHOW POPUP
//        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.last
        fetchCountryAndCity(for: locations.first)
    }
}

// Process location lat long
extension HomeViewModel {
    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let owner = self else {
                return
            }
            owner.currentPlaceMark = placemarks?.last
            if let place = placemarks?.last {
                owner.addressString = """
                name: \(place.name ?? "")
                thoroughfare: \(place.thoroughfare ?? "")
                subthoroughfare: \(place.subThoroughfare ?? "")
                city: \(place.locality ?? "")
                sub city: \(place.subLocality ?? "")
                administrativeArea: \(place.administrativeArea ?? "")
                subadministrativeArea: \(place.subAdministrativeArea ?? "")
                postal code: \(place.postalCode ?? "")
                country code: \(place.isoCountryCode ?? "")
                country: \(place.country ?? "")
                interests: \(owner.interestAreas(areas: place.areasOfInterest ?? []))
            """
            }
        }
    }

    private func interestAreas(areas: [String]) -> String {
        if areas.isEmpty {
            return "No place found"
        }
        return areas.joined(separator: "\n")
    }
}
