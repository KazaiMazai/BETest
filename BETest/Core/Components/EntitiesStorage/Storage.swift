//
//  Storage.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation

public struct Storage: Codable {
    public private(set) var lastModified: Date = .distantPast
    private(set) var schema = ModelSchema()
}

extension Storage {
    mutating func reduce(_ action: Action, env: AppEnvironment) {
        switch action {
        case is Actions.DialogueFlow.Run:
            schema = .init()
        case let action as Actions.TextDataSource.ReceievedDataSuccess:
            lastModified = env.now()
            schema.messages.saveAll(action.value, with: .replace)

        default:
            break
        }
    }
}

extension Storage {
    var messages: Entities<DialogueMessage> {
        schema.messages
    }
}
