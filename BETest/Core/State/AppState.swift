//
//  AppState.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct AppState {
    private(set) var dialogue = Dialogue(delay: 0.5, filename: "data.json")
    private(set) var currentTime = CurrentTime()

    mutating func reduce(_ action: Action) {
        dialogue.reduce(action)
    }
}
