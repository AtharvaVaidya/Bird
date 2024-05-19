//
//  LocationManager.swift
//
//
//  Created by Atharva Vaidya on 18/05/2024.
//

import CoreLocation
import Combine

protocol LocationManagerProtocol {
    var locationUpdates: PassthroughSubject<LocationData, Never> { get }
    
    func startUpdatingLocation()
    
    func stopUpdatingLocation()

    func requestLocationUpdate()
}

class LocationManager: NSObject, LocationManagerProtocol {
    private let locationManager = CLLocationManager()
    
    let locationUpdates = PassthroughSubject<LocationData, Never>()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }

    func startUpdatingLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func requestLocationUpdate() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager didUpdateLocations")
        guard let location = locations.last else { return }
        
        locationUpdates.send(LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date()
        ))
        
        print("locationManager locationData: \(location)")
    }
}
