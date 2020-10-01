//
//  AppState.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct AppState {
    private(set) var prompter = Prompter(delay: 0.5)
    private(set) var currentTime = CurrentTime()

    mutating func reduce(_ action: Action) {
        prompter.reduce(action)
    }
}
