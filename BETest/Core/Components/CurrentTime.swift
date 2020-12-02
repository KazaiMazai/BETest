//
//  CurrentTime.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct CurrentTime: Codable {

    public var time = Date()
    public let interval: Double = 1
    public private(set) var request: RequestState<SingleRequest> = .none

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as Actions.Time.TimeChanged:
            time = action.timestamp
            request = .inProgress(SingleRequest())
        default:
            request = .inProgress(SingleRequest())
        }

    }
}
