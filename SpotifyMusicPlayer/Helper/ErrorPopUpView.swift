//
//  ErrorPopUp.swift
//  SpotifyMusicPlayer
//
//  Created by Marcelino Budiman on 17/05/25.
//
import UIKit

class ErrorPopupView: UIView {

    init(message: String) {
        super.init(frame: .zero)
        setupView(message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(message: String) {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 12
        clipsToBounds = true
        alpha = 0

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        addGestureRecognizer(tap)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -20),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    @objc private func dismissSelf() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
