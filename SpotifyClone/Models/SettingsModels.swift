//
//  SettingsModels.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 16/7/2022.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
