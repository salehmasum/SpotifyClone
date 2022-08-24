//
//  PlaylistViewController.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    public var isOwner = false

    private var playlist: Playlist
    
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
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
        
    }
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var audioTracks = [AudioTrack]()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
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
        
        //add share button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector (didTapShare)
        )
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressLong(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didPressLong(_ gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return
        }
        let trackToDelete = audioTracks[indexPath.item]
        popUpActionSheetToDelete(audioTrack: trackToDelete, indexPath: indexPath)
    }
    
    func popUpActionSheetToDelete(audioTrack: AudioTrack, indexPath: IndexPath) {
        let actionSheet = UIAlertController(
            title: audioTrack.name,
            message: "Would you like to remove this from playlist?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(
            title: "Remove",
            style: .destructive,
            handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.deleteTrackFromPlaylist(trackToDelete: audioTrack, indexPath: indexPath)
        }))
        present(actionSheet, animated: true)
    }
    
    func deleteTrackFromPlaylist(trackToDelete: AudioTrack, indexPath: IndexPath) {
        ApiCaller.shared.removeTrackFromPlaylist(
            track: trackToDelete,
            playlist: self.playlist) { success in
                DispatchQueue.main.async {
                   // if success {
                        self.audioTracks.remove(at: indexPath.row)
                        self.viewModels.remove(at: indexPath.row)
                        self.collectionView.reloadData()
                   // }
                }
            }
    }
    
    @objc private func didTapShare() {
        
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    func fetchData() {
        ApiCaller.shared.getPlaylistDetails(
            for: playlist,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self?.audioTracks = model.tracks.items.compactMap({ $0.track })
                        self?.viewModels = model.tracks.items.compactMap({
                            return RecommendedTrackCellViewModel(
                                name: $0.track.name,
                                artistName: $0.track.artists.first?.name ?? "Unknown Artist",
                                artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                        })
                        self?.collectionView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
    }

}

extension PlaylistViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? RecommendedTrackCollectionViewCell else {
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
            palylistName: playlist.name,
            playlistDescription: playlist.owner.display_name,
            playlistOwnerName: playlist.description,
            playlistArtworkUrl: URL(string: playlist.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //play song
        let selectedTrack = audioTracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: selectedTrack)
    }
    
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAllButton(_ header: PlaylistHeaderCollectionReusableView) {
        //Play all
        PlaybackPresenter.shared.startPlayback(from: self, tracks: self.audioTracks)
    }
}
