//
//  SpeechSynthesizer.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation
import AVFoundation

struct TextToSpeechSideEffects {
    func map(state: AppState, on store: Store) -> TextToSpeechOperator.Request? {
        guard let requestState = state.dialogue.availableForSpeech(at: Date()),
              let item = state.storage.messages.findById(requestState.payload)  else {
            return nil
        }
        
        let request = TextToSpeechOperator.Request(
            id: requestState.id,
            text: item.text) {
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
        return request
    }
}
