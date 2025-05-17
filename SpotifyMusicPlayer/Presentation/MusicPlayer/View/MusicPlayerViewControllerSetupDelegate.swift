//
//  MusicPlayerViewControllerDelegate.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit
import SpotifyiOS

extension MusicPlayerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        return CGSize(width: width, height: width/3)
    }
    
}

extension MusicPlayerViewController: SpotifyPlayerDelegate {
    func didChangePlayerState(_ state: any SPTAppRemotePlayerState) {
        DispatchQueue.main.async {
            self.trackPlayerView.update(with: state)
            self.trackPlayerView.isHidden = false
        }
    }
}

//extension MusicPlayerViewController: UISearchBarDelegate {
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//    
//}
