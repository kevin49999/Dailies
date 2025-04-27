//
//  SKStoreReviewController+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 12/30/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import StoreKit

fileprivate let reviewCutoff = 25
fileprivate let reviewCutoffKey = "review-cutoff"

extension SKStoreReviewController {
    class func incrementReviewAction(defaults: UserDefaults = .standard) {
        let added = defaults.integer(forKey: reviewCutoffKey)
        if added + 1 == reviewCutoff {
            SKStoreReviewController.requestReviewInWindow()
            defaults.set(0, forKey: reviewCutoffKey)
        } else {
            defaults.set(added + 1, forKey: reviewCutoffKey)
        }
    }

    class func requestReviewInWindow() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
