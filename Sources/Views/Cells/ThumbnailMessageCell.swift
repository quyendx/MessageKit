//
//  ThumbnailMessageCell.swift
//  MessageKit
//
//  Created by Quyen Xuan on 7/4/18.
//

import UIKit

class ThumbnailMessageCell: MessageContentCell {
    private lazy var thumbnailStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    /// The label used to display the message's text.
    lazy var messageLabel = MessageLabel()

    /// The `MessageCellDelegate` for the cell.
    override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    private lazy var thumbnailStackViewLeftAnchor = thumbnailStackView.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor)
    private lazy var thumbnailStackViewRightAnchor = messageContainerView.rightAnchor.constraint(equalTo: thumbnailStackView.rightAnchor)
    private lazy var thumbnailStackViewBottomAnchor = messageContainerView.bottomAnchor.constraint(equalTo: thumbnailStackView.bottomAnchor)

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.font = attributes.messageLabelFont

            // Update constraints value
            thumbnailStackViewLeftAnchor.constant = messageLabel.textInsets.left
            thumbnailStackViewRightAnchor.constant = attributes.messageLabelInsets.right
            thumbnailStackViewBottomAnchor.constant = attributes.messageLabelInsets.bottom
        }
    }

    override func setupSubviews() {
        super.setupSubviews()

        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(thumbnailStackView)
        setupConstraints()
    }

    open func setupConstraints() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(755), for: .vertical)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor),
            messageLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor),
            messageLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor)
            ])

        NSLayoutConstraint.activate([
            thumbnailStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            thumbnailStackViewLeftAnchor,
            thumbnailStackViewRightAnchor,
            thumbnailStackViewBottomAnchor
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        messageLabel.attributedText = nil

        for subView in thumbnailStackView.subviews {
            thumbnailStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
    }

    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError("Message display delegate must not be nil")
        }

        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)
        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            switch message.kind {
            case .thumbnail(let content):
                let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
                messageLabel.text = content.title
                messageLabel.textColor = textColor
            default:
                break
            }
        }

        // TODO: Add thumbnail views
        guard case let MessageKind.thumbnail(thumbnail) = message.kind, let urls = thumbnail.previewCanonicalURLs, !urls.isEmpty else {
            thumbnailStackView.subviews.forEach { $0.removeFromSuperview() }
            return
        }

        // Maximum first two urls
        for (index, url) in urls.enumerated() where index < 2 {
            // Add hozirontal separator lines
            if index > 0 {
                let separatorView = UIView(frame: .zero)
                separatorView.backgroundColor = .clear
                separatorView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
                NSLayoutConstraint.activate([
                    separatorView.heightAnchor.constraint(equalToConstant: 2)
                ])
                thumbnailStackView.addArrangedSubview(separatorView)
            }

            // Add thumbnail view
            let thumbnailView = ThumbnailView(frame: .zero)
            thumbnailStackView.addArrangedSubview(thumbnailView)
            displayDelegate.configureThumbnailMessageThumbnailView(thumbnailView, thumbnailURL: url, for: message, at: indexPath, in: messagesCollectionView)
        }
    }
}
