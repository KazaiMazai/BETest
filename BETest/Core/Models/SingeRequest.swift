//
//  SingeRequest.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import Foundation

public struct SingleRequest: Codable {
    public init(id: UUID = UUID()) {
        self.id = id
    }

    public let id: UUID

    public func canPerform(_ now: Date) -> Bool {
        return true
    }
}
