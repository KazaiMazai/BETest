//
//  RequestState.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation

struct PayloadRequest<Payload> {
    let id: UUID
    let payload: Payload
}


public enum RequestState<T: Codable> {
    case none
    case inProgress(T)
    case success
    case failed
}

extension RequestState {
    var isInProgress: Bool {
        guard case .inProgress = self else {
            return false
        }

        return true
    }

    var isSuccess: Bool {
        guard case .success = self else {
            return false
        }

        return true
    }
}

extension RequestState: Codable {
    enum CodingKeys: CodingKey {
        case none
        case inProgress
        case success
        case failed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try container.encode(true, forKey: .none)
        case .inProgress(let state):
            try container.encode(state, forKey: .inProgress)
        case .success:
            try container.encode(true, forKey: .success)
        case .failed:
            try container.encode(true, forKey: .failed)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: container.codingPath,
                                       debugDescription: "Unabled to decode enum.")
            )
        }

        switch key {
        case .none:
            self = .none
        case .inProgress:
            let state = try container.decode(T.self, forKey: .inProgress)
            self = .inProgress(state)
        case .success:
            self = .success
        case .failed:
            self = .failed
        }
    }
}
