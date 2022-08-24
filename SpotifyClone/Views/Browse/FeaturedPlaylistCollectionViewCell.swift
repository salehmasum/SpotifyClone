//
//  FeaturedPlaylistCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 27/7/2022.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    private let playlistCreatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .thin)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // contentView.backgroundColor = .red
        
        contentView.clipsToBounds = true
        
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(playlistCreatorNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playlistCreatorNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height - 30,
            width: contentView.width - 6,
            height: 30
        )
        playlistNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height - 60,
            width: contentView.width - 6,
            height: 30
        )
        
        let imageSize = contentView.height - 70
        playlistCoverImageView.frame = CGRect(
            x: (contentView.width - imageSize)/2,
            y: 3,
            width: imageSize,
            height: imageSize)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistCreatorNameLabel.text = nil
        playlistNameLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel) {
        playlistCreatorNameLabel.text = viewModel.creatorName
        playlistNameLabel.text = viewModel.name
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
    
}
