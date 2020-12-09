//
//  TextToSpeechOperator.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation
import AVFoundation
import PureduxSideEffects


extension TextToSpeechOperator {
    struct Task2: OperatorTask {
        fileprivate let ttsDelegate: TTSDelegate
        let cancelClosure: Command

        func cancel() {
            cancelClosure()
        }
    }

    struct Task1: OperatorTask {
        fileprivate let ttsDelegate: TTSDelegate
        let cancelClosure: Command

        func cancel() {
            cancelClosure()
        }
    }

    enum Task: OperatorTask {
        case speakTask(text: String, delegate: TTSDelegate, cancelClosure: Command)
        case controlTask(Command)

        func cancel() {
            switch self {
            case .speakTask(_, _, cancelClosure: let cancelClosure):
                cancelClosure()
            case .controlTask:
                break
            }
        }
    }

}

class TextToSpeechOperator: Operator<TextToSpeechOperator.Request, TextToSpeechOperator.Task> {
    private let synthesizer = AVSpeechSynthesizer()
    private var synthersizerHandler: TTSDelegate?

    override func createTaskFor(_ request: Request,
                                with completeHandler: @escaping (OperatorResult<Void>) -> Void) -> Task {
        switch request.requestType {
        case let .textToSpeech(text, requestHandler):
            let delegate = TTSDelegate(completeHandlerQueue: queue) {
                switch $0 {
                case .cancel:
                    completeHandler(.cancelled)
                case .continued:
                    requestHandler(.continued)
                case .start:
                    requestHandler(.start)
                case .finish:
                    completeHandler(.success(Void()))
                case .pause:
                    requestHandler(.pause)
                case .failed(let error):
                    completeHandler(.error(error))
                }
            }

            return Task.speakTask(text: text, delegate: delegate,
                         cancelClosure: { [weak self] in
                self?.synthesizer.stopSpeaking(at: .immediate)
            })
        case let .changeState(changeState, _):
            return Task.controlTask({ [weak self] in

                switch changeState {
                case .pause(at: let boundary):
                    self?.synthesizer.stopSpeaking(at: boundary)
                case .stop(at: let boundary):
                    self?.synthesizer.stopSpeaking(at: boundary)
                case .continueSpeaking:
                    self?.synthesizer.continueSpeaking()
                }

                completeHandler(.success(Void()))
            })
        }
    }

    override func run(task: Task, for request: Request) {
        switch task {
        case let .speakTask(text, ttsDelegate, _):
            synthesizer.delegate = ttsDelegate
            let utterance = AVSpeechUtterance(string: text)
            self.synthesizer.speak(utterance)
        case let .controlTask(taskCommand):
            taskCommand()
        }
    }
}


extension TextToSpeechOperator {
    class TTSDelegate: NSObject, AVSpeechSynthesizerDelegate {
        let completeHandlerQueue: DispatchQueue
        let handler: CommandWith<Request.State>


        init(completeHandlerQueue: DispatchQueue,
             handler: @escaping CommandWith<Request.State>) {
            self.handler = handler
            self.completeHandlerQueue = completeHandlerQueue
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
            completeHandlerQueue.async { [weak self] in
                self?.handler(.start)
            }
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
            completeHandlerQueue.async { [weak self] in
                self?.handler(.finish)
            }
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
            completeHandlerQueue.async { [weak self] in
                self?.handler(.pause)
            }
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
            completeHandlerQueue.async { [weak self] in
                self?.handler(.continued)
            }
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
            completeHandlerQueue.async { [weak self] in
                self?.handler(.cancel)
            }
        }
    }

}
