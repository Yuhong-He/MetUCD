//
//  MapViewModel.swift
//  MetUCD
//
//  Created by Yuhong He on 22/11/2023.
//

import CoreLocation
import MapKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.350140, longitude: -6.266155),
        span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
    )

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationPermission() {
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            print("Already got the location permission")
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed: \(status)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated locations: \(locations)")
        guard let location = locations.first else { return }
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        )
    }
    
    func recenterMap() {
        print("In recenterMap function")
        locationManager.startUpdatingLocation()
    }
}
