//
//  SearchResultsViewController.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//
 
import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var sections: [SearchSection] = []
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results: [SearchResult]) {
        
        let artists = results.filter {
            switch $0 {
            case .artist:
                return true
            default:
                return false
            }
        }
        let artistSection = SearchSection(title: "Artists", results: artists)
        let albums = results.filter {
            switch $0 {
            case .album:
                return true
            default:
                return false
            }
        }
        let albumSection = SearchSection(title: "Albums", results: albums)
        let tracks = results.filter {
            switch $0 {
            case .track:
                return true
            default:
                return false
            }
        }
        let trackSection = SearchSection(title: "Songs", results: tracks)
        let playlists = results.filter {
            switch $0 {
            case .playlist:
                return true
            default:
                return false
            }
        }
        let playlistSection = SearchSection(title: "Playlists", results: playlists)
        
        self.sections = [
            trackSection, artistSection, playlistSection, albumSection
        ]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = sections[indexPath.section].results[indexPath.row]
        
        switch result {
        case .artist(let artist):
            guard let artistCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultDefaultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultDefaultTableViewCellViewModel(
                title: artist.name,
                imageURL: URL(string: artist.images?.first?.url ?? "")
            )
            artistCell.configure(with: viewModel)
            return artistCell
        case .album(let album):
            guard let albumCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: album.name,
                subtitle: album.artists.first?.name ?? "",
                imageURL: URL(string: album.images.first?.url ?? "")
            )
            albumCell.configure(with: viewModel)
            return albumCell
        case .track(let track):
            guard let trackCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: track.name,
                subtitle: track.artists.first?.name ?? "",
                imageURL: URL(string: track.album?.images.first?.url ?? "")
            )
            trackCell.configure(with: viewModel)
            return trackCell
        case .playlist(let playlist):
            guard let playlistCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: URL(string: playlist.images.first?.url ?? "")
            )
            playlistCell.configure(with: viewModel)
            return playlistCell
        }
    
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection = sections[section]
        let title = currentSection.title
        return title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }

}

