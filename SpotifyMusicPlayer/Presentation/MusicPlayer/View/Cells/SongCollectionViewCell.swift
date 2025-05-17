//
//  SongCollectionViewCell.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit

class SongCollectionViewCell: UICollectionViewCell {
    
    let songImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let songTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let songArtistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = 2
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let songAlbumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 1
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    static let identifier = "SongCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        contentView.addSubview(songImageView)
        contentView.addSubview(songTitleLabel)
        contentView.addSubview(songArtistLabel)
        contentView.addSubview(songAlbumLabel)
        
        NSLayoutConstraint.activate([
            
            songImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            songImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            songImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            songImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            songTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: songImageView.trailingAnchor, multiplier: 1),
            songTitleLabel.topAnchor.constraint(equalTo: songImageView.topAnchor),
            songTitleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            
            songArtistLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            songArtistLabel.widthAnchor.constraint(equalTo: songTitleLabel.widthAnchor),
            songArtistLabel.topAnchor.constraint(equalToSystemSpacingBelow: songTitleLabel.bottomAnchor, multiplier: 0.5),
            
            songAlbumLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            songAlbumLabel.widthAnchor.constraint(equalTo: songTitleLabel.widthAnchor),
            songAlbumLabel.topAnchor.constraint(equalToSystemSpacingBelow: songArtistLabel.bottomAnchor, multiplier: 0.5),
            songAlbumLabel.bottomAnchor.constraint(equalTo: songImageView.bottomAnchor),
            
            
        ])
        
        
    }
    
    func injectCell(image: String, title: String, artist: [Artist], album: String) {
        self.songTitleLabel.text = title
        self.songArtistLabel.text = artist.map { $0.name }.joined(separator: ", ")
        self.songAlbumLabel.text = album
    }
    
}
