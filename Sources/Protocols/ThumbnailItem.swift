//
//  Thumbnail.swift
//  MessageKit
//
//  Created by Quyen Xuan on 7/4/18.
//

import Foundation

public protocol ThumbnailItem {
    /// The message content
    var title: String { get }

    /// URLs from the content
    var previewCanonicalURLs: [URL]? { get }
}
