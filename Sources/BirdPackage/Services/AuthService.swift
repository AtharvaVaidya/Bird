//
//  AuthService.swift
//
//
//  Created by Atharva Vaidya on 18/05/2024.
//

import Foundation

// MARK: - AuthServiceProtocol

protocol AuthServiceProtocol {
    func authenticate() async throws -> AuthResponse
    func refreshAuth(refreshToken: String) async throws -> AuthResponse
}

// MARK: - AuthService

class AuthService: AuthServiceProtocol {
    private let config: APIConfig

    init(config: APIConfig) {
        self.config = config
    }

    func authenticate() async throws -> AuthResponse {
        guard let url = URL(string: config.baseURL + "/auth") else {
            throw APIError.urlFailure
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    func refreshAuth(refreshToken: String) async throws -> AuthResponse {
        guard let url = URL(string: config.baseURL + "/auth/refresh") else {
            throw APIError.urlFailure
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
}
