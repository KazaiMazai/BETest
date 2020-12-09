//
//  TextToSpeechOperatorRequest.swift
//  BETest
//
//  Created by Sergey Kazakov on 08.12.2020.
//

import Foundation
import PureduxSideEffects
import AVFoundation


extension TextToSpeechOperator.Request {
    enum State {
        case start
        case finish
        case pause
        case cancel
        case continued
        case failed(Error)
    }

    enum SpeakingRequest {
        case pause(at: AVSpeechBoundary)
        case stop(at: AVSpeechBoundary)
        case continueSpeaking
    }

    enum RequestType {
        case textToSpeech(text: String, handler: CommandWith<State>)
        case changeState(SpeakingRequest, handler: CommandWith<Swift.Result<Void, Error>>)
    }
}

extension TextToSpeechOperator {
    struct Request {
        internal init(id: UUID,
                      text: String,
                      handler: @escaping CommandWith<Request.State>) {
            self.id = id
            self.requestType = RequestType.textToSpeech(text: text, handler: handler)
        }

        let id: UUID
        let requestType: RequestType
    }
}

extension TextToSpeechOperator.Request: OperatorRequest {
    func handle(_ result: OperatorResult<Void>) {
        switch requestType {
        case .textToSpeech(_ , let handler):
            switch result {
            case .success():
                handler(.finish)
            case .cancelled:
                handler(.cancel)
            case .error(let error):
                handler(.failed(error))
            }
            
        case .changeState(_, let handler):
            switch result {
            case .success():
                handler(.success(Void()))
            case .cancelled:
                break
            case .error(let error):
                handler(.failure(error))
            }
        }
    }
}
