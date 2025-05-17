//
//  MusicPlayerViewControllerRx.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension MusicPlayerViewController {
    
    func setupRx() {
        setupSearchBarRx()
        setupCollectionViewRx()
    }
    
    func setupSearchBarRx() {
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { query in
                
            }
            .disposed(by: disposeBag)
    }
    
    func setupCollectionViewRx() {
        
    }
    
}
