//
//  AppEnvironment.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation

struct AppEnvironment {
    let now: () -> Date
    let makeUUID: () -> UUID

    init(now: @escaping () -> Date,
         makeUUID: @escaping () -> UUID) {
        self.now = now
        self.makeUUID = makeUUID
    }

    static func defaultAppEnvironment() -> AppEnvironment {
        AppEnvironment(now: { Date() },
                       makeUUID: { UUID() })
    }
}
