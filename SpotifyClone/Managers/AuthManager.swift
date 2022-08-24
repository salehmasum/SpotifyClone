//
//  AuthManager.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//
 
import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "6e02d3002fa04708a41bc36e7e2ad80e"
        static let clientSecret = "b6bbc7d0bd5f460b9a608f970cff2e0e"
        static let tokenAPIURL  = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.iosacademy.io"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-public%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init() {}
    
    private var refreshingToken = false
    
    public var signInUrl: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scopes=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)  
        
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
        
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        //Get Token
        guard let tokenUrl = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
            
        ]
        
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let basicTokenData = basicToken.data(using: .utf8)
        guard let base64String = basicTokenData?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                
                completion(true)
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        
    }
    
    private var onRefreshBlock = [((String) -> Void)]()
    
    
    public func withValidToken(completion: @escaping (String) -> Void ) {
        
        guard !refreshingToken else {
            // Append the completion
            onRefreshBlock.append(completion)
            return
        }
        
        if shouldRefreshToken {
            //Refresh
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
            
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion:  ((Bool) -> Void)?) {
        
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        guard let refreshToken = refreshToken else {
            return
        }
        
        //Refresh The token
        guard let tokenUrl = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let basicTokenData = basicToken.data(using: .utf8)
        guard let base64String = basicTokenData?.base64EncodedString() else {
            print("Failure to get base64")
            completion?(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            self?.refreshingToken = false
            
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("successfully refreshed")
                self?.onRefreshBlock.forEach{ $0(result.access_token) }
                self?.onRefreshBlock.removeAll()
                self?.cacheToken(result: result)
                
                completion?(true)
            }
            catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()

    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil,forKey: "access_token")
        UserDefaults.standard.setValue(nil,forKey: "refresh_token")
        UserDefaults.standard.setValue(nil,forKey: "expirationDate")
        completion(true)
    }
    
}
