//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//

import Foundation

struct UserProfile: Codable {
    
    let display_name: String
    let external_urls: [String: String]
    //let followers: [String: Codable?]
    let id: String
    let images: [APIImage]
    
}



