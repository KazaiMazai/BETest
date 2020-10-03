//
//  PayloadRequest.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation

struct RequestState<Payload> {
    let id: UUID
    let payload: Payload
}
