//
//  CurrentTime.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct CurrentTime: Codable {
    private(set) var time = Date()
    private(set) var shouldReceiveTimeEvents: Bool = true

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as Actions.Time.TimeChanged:
            time = action.timestamp
        default:
            break
        }

    }
}
