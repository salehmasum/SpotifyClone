//
//  Artist.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
    let images: [APIImage]?
}
