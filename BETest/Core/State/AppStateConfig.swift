//
//  AppStateConfig.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation

struct AppStateConfig {
    let timeEventsInterval: TimeInterval
    let dialogueDelay: TimeInterval
    let dialogueDataFilename: String

    static func defaultConfig() -> AppStateConfig {
        AppStateConfig(
            timeEventsInterval: 1,
            dialogueDelay: 0.5,
            dialogueDataFilename: "data.json")
    }
}
