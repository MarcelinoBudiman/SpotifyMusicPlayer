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
        setupLoadingRx()
        setupSearchBarRx()
        setupCollectionViewRx()
    }
    
    func setupLoadingRx() {
        vm.isLoadingRelay
            .observe(on: MainScheduler.instance)
            .subscribe { loading in
                self.isLoading = loading
                
                if loading {
                    LoadingIndicator.shared.show()
                } else {
                    LoadingIndicator.shared.hide()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setupSearchBarRx() {
        
        searchBar.rx.searchButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] query in
                if !(self?.isLoading ?? false) {
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
            .disposed(by: disposeBag)
        
        self.vm.songListPublishSubject
            .observe(on: MainScheduler.instance)
            .flatMap { event -> Observable<[Item]> in
                switch event {
                    
                case .next(let data):
                    return Observable.just(data.tracks.items)
                case .error(let error):
                    // show error message
                    self.showError(message: error.rawValue)
                    return Observable.empty()
                default:
                    return Observable.empty()
                    
                }
            }
            .bind(to: songListCollectionView.rx.items(cellIdentifier: SongCollectionViewCell.identifier, cellType: SongCollectionViewCell.self)) { _, data, cell in
                cell.injectCell(image: data.album.images.isEmpty ? "" : data.album.images[0].url, title: data.name, artist: data.artists, album: data.album.name)
            }
            .disposed(by: disposeBag)
    }
    
}
