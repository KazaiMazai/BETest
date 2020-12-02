//
//  TextToSpeechOperator.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation
import AVFoundation
import PureduxSideEffects

extension TextToSpeechOperator.Request {
    enum State {
        case start
        case finish
        case pause
        case cancel
        case continued
        case failed(Error)
    }
}

extension TextToSpeechOperator {
    struct Request: OperatorRequest {
        func handle(_ result: OperatorResult<Void>) {
            switch result {
            case .success():
                handler(.finish)
            case .cancelled:
                handler(.cancel)
            case .error(let error):
                handler(.failed(error))
            }
        }

        typealias Result = Void
        typealias RequestID = UUID

        internal init(id: UUID,
                      text: String,
                      handler: @escaping CommandWith<Request.State>) {
            self.id = id
            self.text = text
            self.handler = handler
        }

        let id: UUID
        let text: String
        let handler: CommandWith<Request.State>
    }
}

extension TextToSpeechOperator {
    struct Task: OperatorTask {
        fileprivate let ttsDelegate: TTSDelegate
        let cancelClosure: Command

        func cancel() {
            cancelClosure()
        }
    }
}

class TextToSpeechOperator: Operator<TextToSpeechOperator.Request, TextToSpeechOperator.Task> {
    private let synthesizer = AVSpeechSynthesizer()
    private var synthersizerHandler: TTSDelegate?

    override func createTaskFor(_ request: Request, with completeHandler: @escaping (OperatorResult<Void>) -> Void) -> Task {
        let ttsDelegate = TTSDelegate(request: request,
                                      completeHandlerQueue: queue) {
            completeHandler(.success(Void()))
        }

        return Task(ttsDelegate: ttsDelegate,
                    cancelClosure: { [weak self] in
                        self?.synthesizer.stopSpeaking(at: .immediate)
                    })
    }

    override func run(task: Task, for request: Request) {
        synthesizer.delegate = task.ttsDelegate
        let utterance = AVSpeechUtterance(string: request.text)
        self.synthesizer.speak(utterance)

    }
}

private class TTSDelegate: NSObject, AVSpeechSynthesizerDelegate {
    init(request: TextToSpeechOperator.Request,
         completeHandlerQueue: DispatchQueue,
         complete: @escaping () -> Void) {
        self.request = request
        self.completeHandlerQueue = completeHandlerQueue
        self.complete = complete
    }

    let request: TextToSpeechOperator.Request
    let completeHandlerQueue: DispatchQueue
    let complete: () -> Void

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.handler(.start)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            guard let self = self else { return }
            self.complete()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.handler(.pause)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.handler(.continued)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.handler(.cancel)
        }
    }
}
