//
//  CurrentTime.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct CurrentTime: Codable {
    public var time: Date
    public let interval: Double

    init(time: Date, interval: Double, initialRequest: UUID) {
        self.time = time
        self.interval = interval
        self.request = .inProgress(SingleRequest(id: initialRequest))
    }

    public private(set) var request: RequestState<SingleRequest>

    mutating func reduce(_ action: Action, env: AppEnvironment) {
        switch action {
        case is Actions.Time.TimeChanged:
            time = env.now()
            request = .inProgress(SingleRequest(id: env.makeUUID()))
        default:
            break
        }

    }
}
