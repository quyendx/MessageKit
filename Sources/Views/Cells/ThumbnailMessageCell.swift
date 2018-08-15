//
//  ThumbnailMessageCell.swift
//  MessageKit
//
//  Created by Quyen Xuan on 7/4/18.
//

import UIKit

class ThumbnailMessageCell: MessageContentCell {
    static let spacingBetweenThumbnails: CGFloat = 22
    static let spacingBetweenMessageLabelAndThumbnail: CGFloat = 16
    static let thumbnailHeight: CGFloat = 54
    static let maximumThumbnails: Int  = 5

    private lazy var thumbnailStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = ThumbnailMessageCell.spacingBetweenThumbnails / 2
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

    private lazy var messageLabelTopAnchor = messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor)
    private lazy var thumbnailStackViewLeftAnchor = thumbnailStackView.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor)
    private lazy var thumbnailStackViewRightAnchor = messageContainerView.rightAnchor.constraint(equalTo: thumbnailStackView.rightAnchor)
    private lazy var thumbnailStackViewBottomAnchor = messageContainerView.bottomAnchor.constraint(equalTo: thumbnailStackView.bottomAnchor)

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            let insets = UIEdgeInsets(top: 0, left: attributes.messageLabelInsets.left, bottom: 0, right: attributes.messageLabelInsets.right)
            messageLabel.textInsets = insets
            messageLabel.font = attributes.messageLabelFont

            // Update constraints value
            messageLabelTopAnchor.constant = attributes.messageLabelInsets.top
            thumbnailStackViewLeftAnchor.constant = attributes.messageLabelInsets.left
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
        NSLayoutConstraint.activate([
            messageLabelTopAnchor,
            messageLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor),
            messageLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor)
        ])

        thumbnailStackView.setContentCompressionResistancePriority(UILayoutPriority(755), for: .vertical)
        thumbnailStackView.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        NSLayoutConstraint.activate([
            thumbnailStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: ThumbnailMessageCell.spacingBetweenMessageLabelAndThumbnail),
            thumbnailStackViewLeftAnchor,
            thumbnailStackViewRightAnchor,
            thumbnailStackViewBottomAnchor
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.attributedText = nil
        messageLabel.text = nil

        for subView in thumbnailStackView.subviews {
            thumbnailStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
    }

    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
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
                if let font = messageLabel.messageLabelFont {
                    messageLabel.font = font
                }
            default:
                break
            }
        }

        // TODO: Add thumbnail views
        guard case let MessageKind.thumbnail(thumbnail) = message.kind, let urls = thumbnail.previewCanonicalURLs, !urls.isEmpty else {
            thumbnailStackView.subviews.forEach { $0.removeFromSuperview() }
            return
        }

        // First five urls
        for (index, url) in urls.enumerated() where index < ThumbnailMessageCell.maximumThumbnails {
            // Add hozirontal separator lines
            if index > 0 {
                let separatorView = UIView(frame: .zero)
                separatorView.backgroundColor = .clear
                separatorView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
                NSLayoutConstraint.activate([
                    separatorView.heightAnchor.constraint(equalToConstant: 0.5)
                ])
                thumbnailStackView.addArrangedSubview(separatorView)
            }

            // Add thumbnail view
            let thumbnailView = ThumbnailView(frame: .zero)
            thumbnailView.translatesAutoresizingMaskIntoConstraints = false
            thumbnailStackView.addArrangedSubview(thumbnailView)
            displayDelegate.configureThumbnailMessageThumbnailView(thumbnailView, thumbnailURL: url, for: message, at: indexPath, in: messagesCollectionView)
        }
    }
}
