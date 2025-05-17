//
//  TrackPlayerView.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//
import UIKit
import SpotifyiOS
import RxSwift


class TrackPlayerView: UIView {
    
    private let previousButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let progressSlider = UISlider()
    
    private var isPlaying = false
    private var duration: Float = 1.0
    
    private var progressTimer: Timer?
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupActions()
    }
    
    private func setupViews() {
        backgroundColor = .lightGray
        
        previousButton.setTitle("◀︎", for: .normal)
        previousButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        playPauseButton.setTitle("▶︎", for: .normal)
        playPauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        
        nextButton.setTitle("▶︎▶︎", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.value = 0
        
        [previousButton, playPauseButton, nextButton, progressSlider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            previousButton.topAnchor.constraint(equalTo: topAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 44),
            previousButton.widthAnchor.constraint(equalToConstant: 44),
            
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nextButton.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            
            progressSlider.topAnchor.constraint(equalTo: previousButton.bottomAnchor, constant: 8),
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressSlider.heightAnchor.constraint(equalToConstant: 30),
            progressSlider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupActions() {
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(progressSliderChanged(_:event:)), for: .valueChanged)
    }
    
    func bindPlayerState(_ observable: Observable<SPTAppRemotePlayerState>) {
        observable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.updatePlayerState(state)
            })
            .disposed(by: disposeBag)
    }
    
    func updatePlayerState(_ playerState: SPTAppRemotePlayerState) {
        DispatchQueue.main.async {
            self.isPlaying = !playerState.isPaused
            self.duration = Float(playerState.track.duration) / 1000.0
            self.progressSlider.maximumValue = self.duration
            self.progressSlider.value = Float(playerState.playbackPosition) / 1000.0
            self.updatePlayPauseButton()
        }
    }
    
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressSlider), userInfo: nil, repeats: true)
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updatePlayPauseButton() {
        let title = isPlaying ? "❚❚" : "▶︎"
        playPauseButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func playPauseTapped() {
        guard let playerAPI = SpotifySessionManager.shared.appRemote.playerAPI else { return }
        
        if isPlaying {
            playerAPI.pause(nil)
        } else {
            playerAPI.resume(nil)
        }
    }
    
    @objc private func previousTapped() {
        SpotifySessionManager.shared.appRemote.playerAPI?.skip(toPrevious: nil)
    }
    
    @objc private func nextTapped() {
        SpotifySessionManager.shared.appRemote.playerAPI?.skip(toNext: nil)
    }
    
    @objc private func progressSliderChanged(_ slider: UISlider, event: UIEvent) {
        if let touch = event.allTouches?.first, touch.phase == .ended {
            let ms = Int(slider.value * 1000)
            SpotifySessionManager.shared.appRemote.playerAPI?.seek(toPosition: ms, callback: nil)
        }
    }
    
    @objc private func updateProgressSlider() {
        guard isPlaying else { return }
        
        guard let playerAPI = SpotifySessionManager.shared.appRemote.playerAPI else { return }
        
        playerAPI.getPlayerState { [weak self] playerState, error in
            guard let self = self, error == nil, let state = playerState as? SPTAppRemotePlayerState else { return }
            DispatchQueue.main.async {
                self.progressSlider.value = Float(state.playbackPosition) / 1000.0
            }
        }

    }
    
    deinit {
        stopProgressTimer()
    }
}
