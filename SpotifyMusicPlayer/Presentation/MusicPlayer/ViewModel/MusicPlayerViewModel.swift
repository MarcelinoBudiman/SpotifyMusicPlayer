//
//  MusicPlayerViewModel.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation
import RxSwift
import RxRelay

class MusicPlayerViewModel {
    
    let musicPlayerNetworkClient = NetworkSessionClient<MusicPlayerEndPoint>()
    let songListPublishSubject = PublishSubject<ObservableEventEnum<SearchResult>>()
    
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    func fetchMusicByArtist(q: String) async {
        
        self.isLoadingRelay.accept(true)
        
        let parameters = ["q" : "artist:\(q)",
                          "type" : "track",
                          "market" : "ID",]
        
        let result = await musicPlayerNetworkClient.sendRequest(endpoint: .getSongByArtist(urlParameter: parameters), responseModel: SearchResult.self)
        
        switch result {
        case .success(let data):
            self.isLoadingRelay.accept(false)
            songListPublishSubject.onNext(.next(data))
        case .failure(let error):
            // show error state
            self.isLoadingRelay.accept(false)
            print("Error fetching data from server \(error)")
            songListPublishSubject.onNext(.error(error))
        }
            
        
    }
    
}
