//
//  ThumbnailView.swift
//  MessageKit
//
//  Created by Quyen Xuan on 7/4/18.
//

import UIKit

open class ThumbnailView: UIView {
    open lazy var titleLabel: UILabel = {
        let label = MessageLabel()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)

        return label
    }()

    open lazy var detailLabel: UILabel = {
        let label = MessageLabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    open lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Add border to image view
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8

        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0).cgColor

        return imageView
    }()


    private lazy var leftView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 112/255.0, green: 192/255.0, blue: 203/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setup() {
        addSubview(leftView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(imageView)

        // Horizontal constraints
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftView]-[titleLabel]-5-[imageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["leftView": leftView, "titleLabel": titleLabel, "imageView": imageView])
        )

        // Vertical constraints of `leftView`
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftView(>=0)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["leftView": leftView])
        )

        // Constraints between components
        NSLayoutConstraint.activate([
            leftView.widthAnchor.constraint(equalToConstant: 2),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            bottomAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 2)
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
}
