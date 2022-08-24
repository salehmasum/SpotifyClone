//
//  AuthResponse.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 13/7/2022.
//

import Foundation

struct AuthResponse: Codable {
    
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let token_type: String
    
}
