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
    enum Task: OperatorTask {
        case speakTask(text: String, delegate: TTSDelegateProxy, cancelClosure: Command)
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

class TextToSpeechOperator: SingleTaskOperator<TextToSpeechOperator.Request, TextToSpeechOperator.Task> {
    private let synthesizer = AVSpeechSynthesizer()
    private var synthesizerDelegate: TTSDelegateProxy?

    override func createTaskFor(_ request: Request,
                                with taskResultHandler: @escaping (TaskResult<Void, Request.SpeakingState>) -> Void) -> Task {
        switch request.requestType {
        case let .textToSpeech(text, _):
            return createTaskFor(text, with: taskResultHandler)
        case let .changeState(changeState, _):
            return createControlStateTaskTo(changeState: changeState, with: taskResultHandler)
        }
    }

    override func run(task: Task, for request: Request) {
        switch task {
        case let .speakTask(text, ttsDelegate, _):
            synthesizer.delegate = ttsDelegate
            synthesizerDelegate = ttsDelegate
            let utterance = AVSpeechUtterance(string: text)
            self.synthesizer.speak(utterance)
        case let .controlTask(taskCommand):
            taskCommand()
        }
    }
}

private extension TextToSpeechOperator {
    func createTaskFor(_ text: String,
                       with taskResultHandler: @escaping (TaskResult<Void, Request.SpeakingState>) -> Void) -> Task {

        let ttsDelegate = TTSDelegateProxy {
            switch $0 {
            case .cancel:
                taskResultHandler(.cancelled)
            case .continued:
                taskResultHandler(.statusChanged(.continued))
            case .start:
                taskResultHandler(.statusChanged(.start))
            case .finish:
                taskResultHandler(.success(Void()))
            case .pause:
                taskResultHandler(.statusChanged(.pause))
            case .failed(let error):
                taskResultHandler(.failure(error))
            }
        }

        return Task.speakTask(
            text: text,
            delegate: ttsDelegate,
            cancelClosure: { [weak self] in
                self?.synthesizer.stopSpeaking(at: .immediate)
            })
    }

    func createControlStateTaskTo(changeState: Request.SpeakingRequest,
                                  with taskResultHandler: @escaping (TaskResult<Void, Request.SpeakingState>) -> Void) -> Task {
        Task.controlTask({ [weak self] in
            switch changeState {
            case .pause(at: let boundary):
                self?.synthesizer.pauseSpeaking(at: boundary)
            case .stop(at: let boundary):
                self?.synthesizer.stopSpeaking(at: boundary)
            case .continueSpeaking:
                self?.synthesizer.continueSpeaking()
            }

            taskResultHandler(.success(Void()))
        })
    }
}

extension TextToSpeechOperator {
    class TTSDelegateProxy: NSObject, AVSpeechSynthesizerDelegate {
        let handler: CommandWith<Request.SpeakingState>
        
        init(handler: @escaping CommandWith<Request.SpeakingState>) {
            self.handler = handler
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
            handler(.start)
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
            handler(.finish)
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
            handler(.pause)
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
            handler(.continued)
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
            handler(.cancel)
        }
    }
}
