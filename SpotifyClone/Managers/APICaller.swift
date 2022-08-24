//
//  APICaller.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//

import Foundation

final class ApiCaller {
    
    static let shared = ApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK: - Albums
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/albums/" + album.id),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(
                with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                        completion(.success(result))
                    }
                    catch {
                        print(error)
                        completion(.failure(error))
                    }
                    
                }
            task.resume()
        }
    }
    
    public func getCurrentUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/me/albums"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(
                with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        //JSONDecoder().decode(LibraryAlbumsResponse.self, from: data)
                        print(result)
                        completion(.success([]))
                    }
                    catch {
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                    
                }
            task.resume()
        }
    }
    
    public func saveAlbumToLibrary(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/me/albums?ids=\(album.id)"),
            type: .PUT) { baseRequest in
                
                var request = baseRequest
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(
                    with: request) { data, response, error in
                        guard let code = (response as? HTTPURLResponse)?.statusCode,
                                error == nil else {
                            completion(false)
                            return
                        }
                        
                        print(code)
                        completion(code == 201)
                        
                    }
                task.resume()
            }
    }
    
    //MARK: - Playlists
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/playlists/" + playlist.id),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(
                with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                        completion(.success(result))
                    }
                    catch {
                        completion(.failure(error))
                    }
                    
                }
            task.resume()
        }
    }
    
    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void){
        createRequest(
            with: URL(string: Constants.baseURL + "/me/playlists?limit=50"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(
                    with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(.failure(APIError.failedToGetData))
                            return
                        }
                        
                        do {
                            let result = try JSONDecoder().decode(LibraryPlaylistResponse.self, from: data)
                            print(result.items)
                            completion(.success(result.items))
                        }
                        catch {
                            print(error)
                            completion(.failure(error))
                        }
                    }
                task.resume()
            }
    }
    
    public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void){
        
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constants.baseURL + "/users/\(profile.id)/playlists"
                let url = URL(string: urlString)
                
                self?.createRequest(with: url, type: .POST) { baseRequest in
                    var request = baseRequest
                    let param = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
                    
                    let task = URLSession.shared.dataTask(
                        with: request) { data, _, error in
                            guard let data = data, error == nil else {
                                completion(false)
                                return
                            }
                            
                            do {
                                let json = try JSONSerialization.jsonObject(
                                    with: data,
                                    options: .allowFragments)
                                print(json)
                                completion(false)
                                
                            }
                            catch {
                                print(error.localizedDescription)
                                completion(false)
                            }
                        }
                    task.resume()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
     
    public func addTrackToPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void){
        
            createRequest(
                with: URL(string: Constants.baseURL + "/playlists/\(playlist.id)/tracks"),
                type: .POST
            ) { baseRequest in
                var request = baseRequest
                let json = [
                    "uris": ["spotify:track:\(track.id)"]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.dataTask(
                    with: request
                ) { data, _, error in
                        
                    guard let data = data, error == nil else {
                        completion(false)
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(result)
                        if let response = result as? [String: Any],
                            response["snapshot_id"] as? String != nil {
                            
                            completion(true)
                        }else {
                            completion(false)
                        }
                    }
                    catch {
                        completion(false)
                    }
                }
                task.resume()
            }
           
    }
    
    public func removeTrackFromPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void){
            
            createRequest(
                with: URL(string: Constants.baseURL + "/playlists/\(playlist.id)/tracks"),
                type: .DELETE
            ) { baseRequest in
                var request = baseRequest
                let json = [
                    "tracks": [
                        ["uri": "spotify:track:\(track.id)"]
                    ]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.dataTask(
                    with: request
                ) { data, _, error in
                        
                    guard let data = data, error == nil else {
                        completion(false)
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(result)
                        if let response = result as? [String: Any],
                            response["snapshot_id"] as? String != nil {
                            
                            completion(true)
                        }else {
                            completion(false)
                        }
                    }
                    catch {
                        completion(false)
                    }
                }
                task.resume()
            }
           
        
    }
    
    
    
    // MARK: Profile
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/me"),
            type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                    print(result)
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    // MARK: - Browse
    
    public func getNewReleases(completion: @escaping (Result<NewReleaseResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewReleaseResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistsResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/featured-playlists?limit=20"),
                  type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseURL + "/recommendations?limit=41&seed_genres=\(seeds)"),
                      type: .GET
        ) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendedGenres(completion: @escaping ((Result<RecommendedGenresResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + "/recommendations/available-genre-seeds"),
                      type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - Category
    
    public func getCategories(completion: @escaping (Result<[CategoryItem], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/browse/categories?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                    
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(category: CategoryItem, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/browse/categories/\(category.id)/playlists?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self, from: data)
                    let playlists = result.playlists.items
                    print(playlists)
                    completion(.success(playlists))
                    
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Search
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let type = "album,artist,playlist,track"
        
        createRequest(
            with: URL(string: Constants.baseURL + "/search?limit=10&type=\(type)&q=\(encodedQuery)"),
            type: .GET
        ) { request in
            
            print(request.url?.absoluteString ?? "none")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    
                    var searchResults: [SearchResult] = []
                    
                    searchResults.append(contentsOf: result.tracks.items.compactMap { .track(model: $0) })
                    searchResults.append(contentsOf: result.playlists.items.compactMap { .playlist(model: $0) })
                    searchResults.append(contentsOf: result.albums.items.compactMap { .album(model: $0) })
                    searchResults.append(contentsOf: result.artists.items.compactMap { .artist(model: $0) })
                    
                    completion(.success(searchResults))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - Private
    
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            
            guard let apiUrl = url else {
                return
            }
            var request = URLRequest(url: apiUrl)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
            
        }
    }
    
    
}
