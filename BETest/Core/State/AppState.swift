//
//  AppState.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct AppState {
    private(set) var dialogue: Dialogue
    private(set) var currentTime: CurrentTime
    private(set) var storage: Storage

    init(dialogue: Dialogue, currentTime: CurrentTime, storage: Storage) {
        self.dialogue = dialogue
        self.currentTime = currentTime
        self.storage = storage
    }
}

extension AppState {
    static func createStateWith(config: AppStateConfig, env: AppEnvironment) -> AppState {
        AppState(
            dialogue: Dialogue(
                delay: config.dialogueDelay,
                dataFileName: config.dialogueDataFilename),

            currentTime: CurrentTime(
                time: env.now(),
                interval: config.timeEventsInterval,
                initialRequest: env.makeUUID()),

            storage: Storage())
    }
}

extension AppState {
    mutating func reduce(_ action: Action, env: AppEnvironment) {
        dialogue.reduce(action, env: env)
        currentTime.reduce(action, env: env)
        storage.reduce(action, env: env)
    }
}
