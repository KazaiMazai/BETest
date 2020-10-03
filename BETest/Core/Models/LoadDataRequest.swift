//
//  LoadDataRequest.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import Foundation

struct LoadDataRequest {
    let id: UUID
    let filename: String
    let complete: CommandWith<Result<Data, Error>>
}
