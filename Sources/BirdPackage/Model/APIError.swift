//
//  AuthError.swift
//
//
//  Created by Atharva Vaidya on 18/05/2024.
//

import Foundation

enum APIError: Error {
    case urlFailure
    case unauthenticated
    case genericError
}
