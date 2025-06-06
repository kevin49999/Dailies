//
//  Bundle+Extensions.swift
//  TODOs
//
//  Created by Kevin Johnson on 3/28/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
    var buildVersionNumber: String? { infoDictionary?["CFBundleVersion"] as? String }
    var versionNumberString: String { "\(releaseVersionNumber ?? "") (\(buildVersionNumber ?? ""))" }
    
    static func loadNibView<T: UIView>() -> T {
        guard let view = Bundle.main.loadNibNamed(T.storyboardIdentifier, owner: nil, options: nil)?.first as? T else {
            fatalError("Could not load nib view with identifier: \(T.storyboardIdentifier)")
        }
        return view
    }
}
