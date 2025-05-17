//
//  MusicPlayerViewControllerSetupLayout.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit

extension MusicPlayerViewController {
    
    func setupLayout() {
        
        view.backgroundColor = .lightGray
        
        view.addSubview(searchBar)
        view.addSubview(songListCollectionView)
        view.addSubview(trackPlayerView)
        
        NSLayoutConstraint.activate([
            
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            
            songListCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: searchBar.bottomAnchor, multiplier: 2),
            songListCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            songListCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            songListCollectionView.bottomAnchor.constraint(equalTo: trackPlayerView.topAnchor),
            
            trackPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackPlayerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            trackPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
        
    }
    
}
