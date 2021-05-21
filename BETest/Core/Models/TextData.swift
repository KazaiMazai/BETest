//
//  TextData.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct TextData: Codable {
    struct ID: Hashable, Codable {
        let rawValue: Int
    }

    let id: ID
    let text: String
}

