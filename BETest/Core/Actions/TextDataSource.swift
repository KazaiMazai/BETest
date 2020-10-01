//
//  TextDataSource.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

extension Actions {
    enum TextDataSource {}
}

extension Actions.TextDataSource {
    struct ReceievedDataSuccess: Action {
        let value: [TextData]
    }
}
