//
//  ContentViewModel.swift
//  BirdSampleApp
//
//  Created by Atharva Vaidya on 19/05/2024.
//

import Foundation
import Bird

class ContentViewModel: ObservableObject {
    private let locationManager = BirdLocationManager(apiKey: .production("xdk8ih3kvw2c66isndihzke5"))
    
    @Published var locationUpdateError: Error?
    
    init() {
        
    }
    
    func startCapturingLocation() {
        do {
            try locationManager.startCapturingLocation()
        } catch {
            locationUpdateError = error
        }
    }
}
