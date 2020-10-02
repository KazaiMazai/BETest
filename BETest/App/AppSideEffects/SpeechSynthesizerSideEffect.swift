//
//  SpeechSynthesizer.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation
import AVFoundation

struct TextToSpeechDriver {
    let store: Store<AppState, Action>
    let textToSpeechOperator: TextToSpeechOperator

    init(store: Store<AppState, Action>,
         textToSpeechOperator: TextToSpeechOperator) {

        self.store = store
        self.textToSpeechOperator = textToSpeechOperator
    }

    var asObserver: Observer<AppState> {
        Observer(queue: self.textToSpeechOperator.completeHandlerQueue) { state in
            observe(state: state)
            return .active
        }
    }
}

extension TextToSpeechDriver {
    private func observe(state: AppState) {
        guard let itemToSpeak = state.prompter.availableForSpeech(at: Date()) else {
            textToSpeechOperator.process(request: nil)
            return
        }

        let ttsRequest = TextToSpeechRequest(
            id: itemToSpeak.id,
            text: itemToSpeak.payload.text,
            start: bind(Actions.SpeechSynthesizer.StateChange(state: .start)),
            finish: bind(Actions.SpeechSynthesizer.StateChange(state: .finish)),
            pause: bind(Actions.SpeechSynthesizer.StateChange(state: .pause)),
            cancel: bind(Actions.SpeechSynthesizer.StateChange(state: .cancel)),
            continued: bind(Actions.SpeechSynthesizer.StateChange(state: .continued)),
            willStart: bind(Actions.SpeechSynthesizer.StateChange(state: .willStart)))

        textToSpeechOperator.process(request: ttsRequest)
    }

    private func bind(_ action: Action) -> Command {
        { store.dispatch(action: action) }
    }
}

