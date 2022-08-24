//
//  PlaylistHeaderCollectionReusableView.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 30/7/2022.
//


import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAllButton(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image     = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapPlayAllButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapPlayAllButton() {
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAllButton(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = height / 1.8
        imageView.frame = CGRect(x: (width - imageSize)/2, y: 20, width: imageSize, height: imageSize)
        
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width - 20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width - 20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: ownerLabel.bottom, width: width - 20, height: 44)
        
        playAllButton.frame = CGRect(x: width-80, y: height-80, width: 60, height: 60)
    }
    
    func configure(with viewModel: PlaylistHeaderViewViewModel) {
        nameLabel.text = viewModel.palylistName
        ownerLabel.text = viewModel.playlistOwnerName
        descriptionLabel.text = viewModel.playlistDescription
        imageView.sd_setImage(with: viewModel.playlistArtworkUrl,placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
    
}
