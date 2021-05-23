//
//  Schema.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation


public struct ModelSchema: Codable {
    var messages = Entities<DialogueMessage>()
}
