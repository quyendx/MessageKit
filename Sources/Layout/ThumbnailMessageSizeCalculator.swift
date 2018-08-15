import UIKit

open class ThumbnailMessageSizeCalculator: MessageSizeCalculator {
    public var incomingMessageLabelInsets = UIEdgeInsets(top: 7, left: 18, bottom: 15, right: 14)
    public var outgoingMessageLabelInsets = UIEdgeInsets(top: 7, left: 14, bottom: 15, right: 18)

    public var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)

    internal func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }

    override open func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = messageLabelInsets(for: message)
        return maxWidth - textInsets.horizontal
    }

    override open func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)

        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        let urls: [URL]

        switch message.kind {
        case .thumbnail(let item):
            urls = item.previewCanonicalURLs ?? []
            attributedText = NSAttributedString(string: item.title, attributes: [.font: messageLabelFont])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }

        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)
        messageContainerSize.width = maxWidth

        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical

        // Add vertical size of thumbnails
        // TODO: Find an other way to calculate height of thumbnails view
        var thumbnailViewsHeight: CGFloat = CGFloat(urls.count) * ThumbnailMessageCell.thumbnailHeight + ThumbnailMessageCell.spacingBetweenMessageLabelAndThumbnail
        if urls.count > 1 {
            thumbnailViewsHeight += CGFloat(urls.count - 1) * ThumbnailMessageCell.spacingBetweenThumbnails
        }
        messageContainerSize.height += thumbnailViewsHeight

        return messageContainerSize
    }

    override open func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont
    }
}
