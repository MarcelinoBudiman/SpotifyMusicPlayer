//
//  LoadingIndicator.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//

import UIKit

final class LoadingIndicator {
    
    static let shared = LoadingIndicator()
    
    private var backgroundView: UIView?
    private var spinner: UIActivityIndicatorView?

    private init() {}
    
    func show(on view: UIView? = nil) {
        guard backgroundView == nil else { return }

        let parentView = view ?? UIApplication.shared.keyWindow ?? UIView()
        
        let background = UIView(frame: parentView.bounds)
        background.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false

        background.addSubview(spinner)
        parentView.addSubview(background)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: background.centerYAnchor)
        ])
        
        self.backgroundView = background
        self.spinner = spinner
    }
    
    func hide() {
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        backgroundView?.removeFromSuperview()
        
        spinner = nil
        backgroundView = nil
    }
}
