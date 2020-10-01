//
//  AppState.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct AppState: Codable {
    private(set) var reader = Reader()
    private(set) var currentTime = CurrentTime()

    mutating func reduce(_ action: Action) {
        reader.reduce(action)
    }
}
