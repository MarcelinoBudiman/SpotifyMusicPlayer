//
//  MusicPlayerViewController.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit
import RxSwift

class MusicPlayerViewController: UIViewController {
    
    let searchBar: UISearchBar = {
       
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Artist"
        searchBar.backgroundColor = .lightGray
        searchBar.searchBarStyle = .minimal
        
        return searchBar
        
    }()
    
    let songListCollectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .lightGray
        
        collectionView.register(SongCollectionViewCell.self, forCellWithReuseIdentifier: SongCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    let vm = MusicPlayerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupRx()
        // Do any additional setup after loading the view.
        
        setupHideKeyboard()
        
        SpotifySessionManager.shared.connectAppRemote()
    }

}
