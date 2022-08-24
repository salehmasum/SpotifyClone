//
//  AlbumViewController.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 29/7/2022.
//

import UIKit

class AlbumViewController: UIViewController {

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection in
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
            //Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                ),
                subitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
            ]
            return section
        })
    )
    
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    private var audioTracks = [AudioTrack]()
    private var album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.register(
            AlbumTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier
        )
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapAction))
    }
    
    @objc func didTapAction() {
        let actionSheet = UIAlertController(
            title: album.name,
            message: "Actions",
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Save Album", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            ApiCaller.shared.saveAlbumToLibrary(album: strongSelf.album) { success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)
                    print(success)
                }else{
                    HapticsManager.shared.vibrate(for: .error)
                    print("Error")
                }
                
            }
        }))
        present(actionSheet, animated: true)
    }
    
    func fetchData() {
        
        ApiCaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.audioTracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap({
                        return AlbumCollectionViewCellViewModel(
                            name: $0.name,
                            artistName: $0.artists.first?.name ?? "Unknown Artist")
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? AlbumTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = PlaylistHeaderViewViewModel(
            palylistName: album.name,
            playlistDescription: album.artists.first?.name,
            playlistOwnerName: "Release Date: \(String.formattedDate(string: album.release_date))",
            playlistArtworkUrl: URL(string: album.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //play song
        var selectedTrack = self.audioTracks[indexPath.item]
        selectedTrack.album = self.album
        PlaybackPresenter.shared.startPlayback(from: self, track: selectedTrack)
    }
    
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAllButton(_ header: PlaylistHeaderCollectionReusableView) {
        //Playlist play all in queue
        //Play all
        let tracksWithAlbum: [AudioTrack] = audioTracks.compactMap({
            var track = $0
            track.album = self.album
            return track
        })
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
        
    }
}
