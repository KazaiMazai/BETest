//
//  TextToSpeechRequest.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation

struct TextToSpeechRequest {
    internal init(id: UUID,
                  text: String,
                  start: @escaping Command,
                  finish: @escaping Command,
                  pause: @escaping Command,
                  cancel: @escaping Command,
                  continued: @escaping Command) {
        self.id = id
        self.text = text
        self.start = start
        self.finish = finish
        self.pause = pause
        self.cancel = cancel
        self.continued = continued
    }

    let id: UUID
    let text: String
    let start: Command
    let finish: Command
    let pause: Command
    let cancel: Command
    let continued: Command 
}
