//
//  APIConfig.swift
//
//
//  Created by Atharva Vaidya on 18/05/2024.
//

import Foundation

protocol APIConfig {
    var baseURL: String { get }
    var apiKey: String { get }
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}

struct DevAPIConfig: APIConfig {
    var baseURL: String { "https://dummy-api-mobile.api.sandbox.bird.one" }
    
    @UserDefault(key: "birdDevAccessToken", defaultValue: nil)
    var accessToken: String?
    
    @UserDefault(key: "birdDevRefreshToken", defaultValue: nil)
    var refreshToken: String?
    
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
}

struct ProdAPIConfig: APIConfig {
    var baseURL: String { "https://dummy-api-mobile.api.sandbox.bird.one" }
    
    @UserDefault(key: "birdProdAccessToken", defaultValue: nil)
    var accessToken: String?
    
    @UserDefault(key: "birdProdRefreshToken", defaultValue: nil)
    var refreshToken: String?
    
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
}
