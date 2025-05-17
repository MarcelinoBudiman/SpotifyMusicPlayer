//
//  TrackPlayerView.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//
import UIKit
import SpotifyiOS

class TrackPlayerView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .black
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    
    private let artistLabel: UILabel = {
        let artistLabel = UILabel()
        artistLabel.font = UIFont.systemFont(ofSize: 12)
        artistLabel.textColor = .darkGray
        artistLabel.numberOfLines = 1
        
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        return artistLabel
    }()
    
    
    let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isPlaying = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupAction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
        setupAction()
    }
    
    private func setupUI() {
        backgroundColor = .lightGray
        layer.cornerRadius = 12
        clipsToBounds = true

    }
    
    private func setupLayout() {
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(artistLabel)
        addSubview(playPauseButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 44),
            imageView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),

            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 30),
            playPauseButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    private func setupAction() {
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
    }

    func update(with playerState: SPTAppRemotePlayerState) {
        titleLabel.text = playerState.track.name
        artistLabel.text = playerState.track.artist.name
        isPlaying = !playerState.isPaused
        updatePlayPauseIcon()
        
        self.imageView.kf.setImage(with: URL(string: playerState.track.imageIdentifier))
        
    }

    private func updatePlayPauseIcon() {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    @objc private func didTapPlayPause() {
        guard SpotifySessionManager.shared.appRemote.isConnected else { return }

        if isPlaying {
            SpotifySessionManager.shared.appRemote.playerAPI?.pause(nil)
        } else {
            SpotifySessionManager.shared.appRemote.playerAPI?.resume(nil)
        }
    }
}
