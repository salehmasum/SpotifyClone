//
//  SearchResult.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 13/8/2022.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: SearchAlbumResponse
    let artists: SearchArtistResponse
    let playlists: SearchPlaylistResponse
    let tracks: SearchTracksResponse
}

struct SearchAlbumResponse: Codable {
    let items: [Album]
}

struct SearchArtistResponse: Codable {
    let items: [Artist]
}

struct SearchPlaylistResponse: Codable {
    let items: [Playlist]
}

struct SearchTracksResponse: Codable {
    let items: [AudioTrack]
}

