//
//  LibraryAlbumsViewController.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 19/8/2022.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    var albums = [Album]()
    var playlists = [Playlist]()
    
    private let noAlbumsView = ActionLabelView()
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        setupNoAlbumsView()
        fetchData()
        
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width - 150)/2, y: (view.height-150)/2, width: 150, height: 150)
       // noAlbumsView.center = view.center
        tableView.frame = view.bounds
    }
    
    //Temporary Test code . Will be fixed soon !!//
    private func fetchData() {
        ApiCaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchCurrentUsersSavedAlbums() {
        ApiCaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    fileprivate func setupNoAlbumsView() {
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(
            text: "You don't have any saved albums yet",
            actionTitle: "Browse")
        )
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            //show label
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        }else {
            //show table
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }

}


extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    
    
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
    
}


extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubtitleTableViewCell.identifier,
            for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        
        let album = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: album.name,
            subtitle: album.owner.display_name,
            imageURL: URL(string: album.images.first?.url ?? "" ))
        )
                       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let playlist = playlists[indexPath.row]
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
