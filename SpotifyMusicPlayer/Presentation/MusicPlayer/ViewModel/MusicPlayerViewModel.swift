//
//  MusicPlayerViewModel.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import Foundation
import RxSwift

class MusicPlayerViewModel {
    
    let musicPlayerNetworkClient = NetworkSessionClient<MusicPlayerEndPoint>()
    let songListPublishSubject = PublishSubject<ObservableEventEnum<SearchResult>>()
    
    var isLoading = false
    
    func fetchMusicByArtist(q: String) async {
        
        self.isLoading = true
        
        let parameters = ["q" : "artist:\(q)",
                          "type" : "track",
                          "market" : "ID",
                          "limit" : "10",
                          "offset" : "5",]
        
        let result = await musicPlayerNetworkClient.sendRequest(endpoint: .getSongByArtist(urlParameter: parameters), responseModel: SearchResult.self)
        
        switch result {
        case .success(let data):
            self.isLoading = false
            songListPublishSubject.onNext(.next(data))
        case .failure(let error):
            // show error state
            self.isLoading = false
            print("Error fetching data from server \(error)")
            songListPublishSubject.onNext(.error(error))
        }
            
        
    }
    
}
