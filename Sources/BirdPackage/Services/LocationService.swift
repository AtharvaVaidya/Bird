//
//  NetworkManager.swift
//
//
//  Created by Atharva Vaidya on 18/05/2024.
//

import Foundation

protocol LocationServiceProtocol {
    func sendLocationData(_ locationData: LocationData) async throws
}

class LocationService: LocationServiceProtocol {
    private struct LocationUpdateRequest: Encodable {
        let longitude: Double
        let latitude: Double
    }
    
    private let config: APIConfig
    
    init(config: APIConfig) {
        self.config = config
    }
    
    func sendLocationData(_ locationData: LocationData) async throws {
        guard let url = URL(string: config.baseURL + "/location") else {
            throw APIError.urlFailure
        }
        
        guard let accessToken = config.accessToken else {
            throw APIError.unauthenticated
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            LocationUpdateRequest(
                longitude: locationData.longitude,
                latitude: locationData.latitude
            )
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                if errorResponse.error == "Invalid access token." {
                    throw APIError.unauthenticated
                }
            }
            
            throw APIError.genericError
        }
    }
}

