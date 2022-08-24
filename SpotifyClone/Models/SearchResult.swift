//
//  SearchResult.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 13/8/2022.
//

import Foundation

enum SearchResult {
    case album(model: Album)
    case artist(model: Artist)
    case playlist(model: Playlist)
    case track(model: AudioTrack)
}
