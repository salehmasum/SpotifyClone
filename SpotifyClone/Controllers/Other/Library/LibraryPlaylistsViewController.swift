//
//  LibraryPlaylistsViewController.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 19/8/2022.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {

    var playlists = [Playlist]()
    private let noPlaylistView = ActionLabelView()
    
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
        setupNoPlaylistView()
        fetchCurrentUsersPlaylists()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistView.center = view.center
        tableView.frame = view.bounds
    }
    
    private func fetchCurrentUsersPlaylists() {
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
    
    fileprivate func setupNoPlaylistView() {
        view.addSubview(noPlaylistView)
        noPlaylistView.delegate = self
        noPlaylistView.configure(with: ActionLabelViewViewModel(
            text: "You don't have any playlists yet",
            actionTitle: "Create")
        )
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            //show label
            noPlaylistView.isHidden = false
            tableView.isHidden = true
        }else {
            //show table
            tableView.reloadData()
            noPlaylistView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    public func showCreatePlaylistAlert() {
        //Show Creation UI
        let alert = UIAlertController(
            title: "New Playlists",
            message: "Enter playlist name",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Playlist Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            self.createPlaylistWithName(name: text)
            
        }))
        present(alert, animated: true)
    }

}


extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    
    
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
    
    func createPlaylistWithName(name: String) {
        ApiCaller.shared.createPlaylist(with: name) { [weak self] success in
            if success {
                HapticsManager.shared.vibrate(for: .success)
                //Refresh list of playlists
                self?.fetchCurrentUsersPlaylists()
            }
            else {
                HapticsManager.shared.vibrate(for: .error)
                print("Failed to create playlists because" + "Insufficient client scope" + " status code is 403")
            }
        }
    }
}


extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubtitleTableViewCell.identifier,
            for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: playlist.name,
            subtitle: playlist.owner.display_name,
            imageURL: URL(string: playlist.images.first?.url ?? "" ))
        )
                       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let playlist = playlists[indexPath.row]
        
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true, completion: nil)
            return
        }
        
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
