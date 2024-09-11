//
//  EKMessageContentView.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/19/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

 class EKMessageContentView: UIView {
    
    // MARK: Properties
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private var horizontalConstraints: QLAxisConstraints!
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var labelsOffsetConstraint: NSLayoutConstraint!
        
     var titleContent: EKProperty.LabelContent! {
        didSet {
            titleLabel.content = titleContent
        }
    }
    
     var subtitleContent: EKProperty.LabelContent! {
        didSet {
            subtitleLabel.content = subtitleContent
        }
    }
    
     var titleAttributes: EKProperty.LabelStyle! {
        didSet {
            titleLabel.style = titleAttributes
        }
    }
    
     var subtitleAttributes: EKProperty.LabelStyle! {
        didSet {
            subtitleLabel.style = subtitleAttributes
        }
    }
    
     var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
     var subtitle: String! {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
     var verticalMargins: CGFloat = 20 {
        didSet {
            topConstraint.constant = verticalMargins
            bottomConstraint.constant = -verticalMargins
            layoutIfNeeded()
        }
    }
    
     var horizontalMargins: CGFloat = 20 {
        didSet {
            horizontalConstraints.first.constant = horizontalMargins
            horizontalConstraints.second.constant = -horizontalMargins
            layoutIfNeeded()
        }
    }
    
     var labelsOffset: CGFloat = 8 {
        didSet {
            labelsOffsetConstraint.constant = labelsOffset
            layoutIfNeeded()
        }
    }
    
    // MARK: Setup
    
     init() {
        super.init(frame: UIScreen.main.bounds)
        clipsToBounds = true
        setupTitleLabel()
        setupSubtitleLabel()
    }
    
     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        topConstraint = titleLabel.layoutToSuperview(.top, offset: verticalMargins)
        horizontalConstraints = titleLabel.layoutToSuperview(axis: .horizontally, offset: horizontalMargins)
        titleLabel.forceContentWrap(.vertically)
    }
    
    private func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        labelsOffsetConstraint = subtitleLabel.layout(.top, to: .bottom, of: titleLabel, offset: labelsOffset)
        subtitleLabel.layout(to: .left, of: titleLabel)
        subtitleLabel.layout(to: .right, of: titleLabel)
        bottomConstraint = subtitleLabel.layoutToSuperview(.bottom, offset: -verticalMargins, priority: .must)
        subtitleLabel.forceContentWrap(.vertically)
    }
    
    private func setupInterfaceStyle() {
        titleLabel.textColor = titleContent?.style.color(for: traitCollection)
        subtitleLabel.textColor = subtitleContent?.style.color(for: traitCollection)
    }
    
     override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupInterfaceStyle()
    }
}
