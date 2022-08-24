//
//  RecommendedTrackCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 27/7/2022.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.clipsToBounds = true
        
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewSize = contentView.height - 4
        albumCoverImageView.frame = CGRect(
            x: 5,
            y: 2,
            width: imageViewSize,
            height: imageViewSize)
        
        trackNameLabel.frame = CGRect(
            x: albumCoverImageView.right + 10,
            y: 0,
            width: contentView.width - albumCoverImageView.right - 15,
            height: contentView.height/2
        )
        
        artistNameLabel.frame = CGRect(
            x: albumCoverImageView.right + 10,
            y: trackNameLabel.bottom,
            width: contentView.width - albumCoverImageView.right - 15,
            height: contentView.height/2
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artistNameLabel.text = nil
        trackNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: RecommendedTrackCellViewModel) {
        artistNameLabel.text = viewModel.artistName
        trackNameLabel.text = viewModel.name
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
    
}
