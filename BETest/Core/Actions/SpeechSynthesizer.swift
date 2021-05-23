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
        let state: SyntesizerState
    }
}
 
