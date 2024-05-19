//
//  BirdLocationManager.swift
//
//
//  Created by Atharva Vaidya on 18/05/2024.
//

import Foundation
import Combine

// MARK: - BirdLocationManagerProtocol

public protocol BirdLocationManagerProtocol {
    /// Starts capturing location info and sends it to Bird.
    func startCapturingLocation() async throws

    /// Requests one specific location update sends it to Bird.
    func requestLocationUpdate() async throws
}

// MARK: - BirdLocationManager
/// Manages location updates for Bird.
public class BirdLocationManager: BirdLocationManagerProtocol {
    private let authService: AuthServiceProtocol
    private let locationService: LocationServiceProtocol
    private let locationManager: LocationManagerProtocol
    private var apiConfig: APIConfig
    
    private var authCredentialsLoaded: Bool {
        apiConfig.accessToken != nil && apiConfig.refreshToken != nil
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var authenticationInProgress = false
    private var refreshingAccessToken = false

    init(
        authService: AuthServiceProtocol,
        locationService: LocationServiceProtocol,
        locationManager: LocationManagerProtocol,
        apiConfig: APIConfig
    ) {
        self.authService = authService
        self.locationService = locationService
        self.locationManager = locationManager
        self.apiConfig = apiConfig
        
        authenticate()
        setupObservers()
    }

    /// Convenience initializer for creating a BirdLocationManager with a specified API key.
    ///
    /// - Parameter apiKey: The API key for either development or production mode.
    public convenience init(apiKey: APIKey) {
        let apiConfig: APIConfig

        switch apiKey {
        case let .devMode(key):
            apiConfig = DevAPIConfig(apiKey: key)
        case let .production(key):
            apiConfig = ProdAPIConfig(apiKey: key)
        }

        self.init(
            authService: AuthService(config: apiConfig),
            locationService: LocationService(config: apiConfig),
            locationManager: LocationManager(),
            apiConfig: apiConfig
        )
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }

    /// Starts capturing location information and sending it to the Bird service.
    ///
    /// - Throws: An error if authentication credentials are not loaded.
    public func startCapturingLocation() throws {
        print("Starting to capture location")
        
        guard authCredentialsLoaded else {
            throw BirdError.authenticationError
        }
        
        locationManager.startUpdatingLocation()
    }

    /// Requests a single location update and sends it to the Bird service.
    ///
    /// - Throws: An error if authentication credentials are not loaded.
    public func requestLocationUpdate() throws {
        guard authCredentialsLoaded else {
            throw BirdError.authenticationError
        }
        
        locationManager.requestLocationUpdate()
    }
}

extension BirdLocationManager {
    /// Only starts the authentication process if needed.
    private func authenticate() {
        guard !authenticationInProgress else { return }
        
        authenticationInProgress = true
        
        Task.retrying { [self] in
            do {
                let response = try await authService.authenticate()
                authenticationInProgress = false
                apiConfig.accessToken = response.accessToken
                apiConfig.refreshToken = response.refreshToken
            } catch {
                authenticationInProgress = false
                throw BirdError.authenticationError
            }
        }
    }
    
    /// Refreshes the auth tokens.
    private func refreshAuthentication() {
        guard let refreshToken = apiConfig.refreshToken, !refreshingAccessToken else {
            return
        }
        
        refreshingAccessToken = true
        
        Task.retrying { [self] in
            do {
                let response = try await authService.refreshAuth(refreshToken: refreshToken)
                refreshingAccessToken = false
                apiConfig.accessToken = response.accessToken
                apiConfig.refreshToken = response.refreshToken
            } catch {
                refreshingAccessToken = false
                authenticate()
            }
        }
    }
    
    private func setupObservers() {
        locationManager
            .locationUpdates
            .sink { [weak self] locationData in
                self?.sendLocationDataToBird(locationData)
            }
            .store(in: &cancellables)
    }
    
    private func sendLocationDataToBird(_ locationData: LocationData) {
        Task.retrying { [self] in
            do {
                print("sending location data to bird...")
                try await locationService.sendLocationData(locationData)
            } catch {
                guard let error = error as? APIError else {
                    print(error)
                    return
                }
                
                switch error {
                case .urlFailure:
                    print(error)
                case .unauthenticated:
                    if authCredentialsLoaded {
                        refreshAuthentication()
                    } else {
                        authenticate()
                    }
                case .genericError:
                    print("Bird had an unrecoverable error in sending location.")
                }
            }
        }
    }
}
