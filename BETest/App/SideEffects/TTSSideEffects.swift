//
//  SpeechSynthesizer.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation
import AVFoundation
//
//struct TextToSpeechDriver {
//    let store: Store<AppState, Action>
//    let textToSpeechOperator: TextToSpeechOperator
//
//    init(store: Store<AppState, Action>,
//         textToSpeechOperator: TextToSpeechOperator) {
//
//        self.store = store
//        self.textToSpeechOperator = textToSpeechOperator
//    }
//
//    var asObserver: Observer<AppState> {
//        Observer(queue: self.textToSpeechOperator.completeHandlerQueue) { state in
//            observe(state: state)
//            return .active
//        }
//    }
//}

struct TTSSideEffects {
    func map(state: AppState, on store: Store) -> [TextToSpeechOperator.Request] {
        guard let itemToSpeak = state.dialogue.availableForSpeech(at: Date()) else {
            return []
        }

        let request = TextToSpeechOperator.Request(
            id: itemToSpeak.id,
            text: itemToSpeak.payload.text) {
            switch $0 {
            case .start:
                store.dispatch(action: Actions.SpeechSynthesizer.StateChange(state: .start))
            case .finish:
                store.dispatch(action: Actions.SpeechSynthesizer.StateChange(state: .finish))
            case .pause:
                store.dispatch(action: Actions.SpeechSynthesizer.StateChange(state: .pause))
            case .cancel:
                store.dispatch(action: Actions.SpeechSynthesizer.StateChange(state: .cancel))
            case .continued:
                store.dispatch(action: Actions.SpeechSynthesizer.StateChange(state: .continued))
            case .failed(let error):
                store.dispatch(action: Actions.SpeechSynthesizer.StateChange(state: .failed(error)))
            }
        }
        return [request]
    }
}
//
//extension TextToSpeechDriver {
//    private func observe(state: AppState) {
//        guard let itemToSpeak = state.dialogue.availableForSpeech(at: Date()) else {
//            textToSpeechOperator.process(request: nil)
//            return
//        }
//
//
//        let ttsRequest = TextToSpeechRequest(
//            id: itemToSpeak.id,
//            text: itemToSpeak.payload.text,
//            start: bind(Actions.SpeechSynthesizer.StateChange(state: .start)),
//            finish: bind(Actions.SpeechSynthesizer.StateChange(state: .finish)),
//            pause: bind(Actions.SpeechSynthesizer.StateChange(state: .pause)),
//            cancel: bind(Actions.SpeechSynthesizer.StateChange(state: .cancel)),
//            continued: bind(Actions.SpeechSynthesizer.StateChange(state: .continued)))
//
//        textToSpeechOperator.process(request: ttsRequest)
//    }
//
//    private func bind(_ action: Action) -> Command {
//        { store.dispatch(action: action) }
//    }
//}

