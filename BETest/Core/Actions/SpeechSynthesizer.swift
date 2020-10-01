//
//  TextReader.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

extension Actions {
    enum SpeechSynthesizer {}
}

extension Actions.SpeechSynthesizer {
    struct StateChange: Action {
        let state: State
    }
}

extension Actions.SpeechSynthesizer.StateChange {
    enum State {
        case start
        case finish
        case pause
        case cancel
        case continued
        case willStart
    }
}
