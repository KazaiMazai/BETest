//
//  TextReader.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

extension Actions {
    enum TextReader {}
}

extension Actions.TextReader {
    struct ReadingStateChange: Action {
        let state: State
    }
}

extension Actions.TextReader.ReadingStateChange {
    enum State {
        case start
        case finish
        case pause
        case cancel
        case continued
        case willStart
    }
}
