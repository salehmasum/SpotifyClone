//
//  AlbumTrackCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 7/8/2022.
//

import Foundation
import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumTrackCollectionViewCell"
    
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
    
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackNameLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: contentView.width - 15,
            height: contentView.height/2
        )
        
        artistNameLabel.frame = CGRect(
            x: 10,
            y: trackNameLabel.bottom,
            width: contentView.width - 15,
            height: contentView.height/2
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artistNameLabel.text = nil
        trackNameLabel.text = nil
    }
    
    func configure(with viewModel: AlbumCollectionViewCellViewModel) {
        artistNameLabel.text = viewModel.artistName
        trackNameLabel.text = viewModel.name
    }
    
}

