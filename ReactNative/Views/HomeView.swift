//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React
import Storage

class HomeView: UIView, ReactViewTheme {
    private var speedDials: [Site]?
    private var pinnedSites: [Site]?
    private var isNewsEnabled = true
    private var isNewsImagesEnabled = true
    private lazy var reactView: UIView = {
        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Home",
            initialProperties: [
                "theme": Self.getTheme(),
                "speedDials": self.speedDials!.map { $0.toDict() },
                "pinnedSites": self.pinnedSites!.map { $0.toDict() },
                "isNewsEnabled": self.isNewsEnabled,
                "isNewsImagesEnabled": self.isNewsImagesEnabled,
            ]
        )

        reactView.backgroundColor = .clear
        return reactView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(
        speedDials: [Site],
        pinnedSites: [Site],
        isNewsEnabled: Bool,
        isNewsImagesEnabled: Bool
    ) {
        self.init(frame: .zero)
        self.pinnedSites = pinnedSites
        self.speedDials = speedDials
        self.isNewsEnabled = isNewsEnabled
        self.isNewsImagesEnabled = isNewsImagesEnabled

        self.addSubview(self.reactView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.reactView.frame = self.bounds
    }
}
