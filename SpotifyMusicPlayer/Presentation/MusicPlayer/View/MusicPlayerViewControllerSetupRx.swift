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
            .subscribe { [weak self] query in
                if !(self?.vm.isLoading ?? false) {
                    Task {
                        await self?.vm.fetchMusicByArtist(q: query)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setupCollectionViewRx() {
        
        self.songListCollectionView.rx
            .setDelegate(self)
        
        self.vm.songListPublishSubject
            .observe(on: MainScheduler.instance)
            .flatMap { event -> Observable<[Item]> in
                switch event {
                    
                case .next(let data):
                    return Observable.just(data.tracks.items)
                case .error(let error):
                    // show error message
                    return Observable.empty()
                default:
                    return Observable.empty()
                    
                }
            }
            .bind(to: songListCollectionView.rx.items(cellIdentifier: SongCollectionViewCell.identifier, cellType: SongCollectionViewCell.self)) { _, data, cell in
                cell.injectCell(image: "", title: data.name, artist: data.artists, album: data.album.name)
            }
            .disposed(by: disposeBag)
    }
    
}
