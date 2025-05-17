//
//  MusicPlayerViewControllerFunction.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit

extension MusicPlayerViewController {
    
    func showError(message: String) {
        DispatchQueue.main.async {
            let popup = ErrorPopupView(message: message)
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window.addSubview(popup)
            }
        }
    }

    func setupHideKeyboard() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
