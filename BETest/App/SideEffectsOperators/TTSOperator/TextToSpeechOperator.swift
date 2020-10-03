//
//  TextToSpeechOperator.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation
import AVFoundation

class TextToSpeechOperator {
    private let synthesizer = AVSpeechSynthesizer()
    let completeHandlerQueue: DispatchQueue

    private var activeRequest: TextToSpeechRequest?
    private var completedRequests: Set<UUID> = []
    private var synthersizerHandler: SpeechSynthesizerRequestEventsHandler?

    init(completeHandlerQueue: DispatchQueue = DispatchQueue(label: "TTS Operator")) {
        self.completeHandlerQueue = completeHandlerQueue
    }

    func process(request: TextToSpeechRequest?) {
        guard let request = request else {
            cancelCurrent()
            return
        }

        if completedRequests.contains(request.id) {
            return
        }

        guard activeRequest?.id != request.id else {
            return
        }

        print("TTS:\t\t \(request.id)) \n text: \(request.text) \n")

        if activeRequest != nil {
            cancelCurrent()
        }

        speak(request: request)
    }
}

extension TextToSpeechOperator {
    private func cancelCurrent() {
        synthersizerHandler = nil
        synthesizer.delegate = nil
        synthesizer.stopSpeaking(at: .immediate)
        activeRequest?.cancel()
        activeRequest = nil
    }

    private func speak(request: TextToSpeechRequest) {
        activeRequest = request
        synthersizerHandler = SpeechSynthesizerRequestEventsHandler(request: request,
                                                               completeHandlerQueue: completeHandlerQueue,
                                                               complete: complete)
        synthesizer.delegate = synthersizerHandler
        let utterance = AVSpeechUtterance(string: request.text)
        synthesizer.speak(utterance)
    }

    private func complete(request: TextToSpeechRequest) {
        completedRequests.insert(request.id)
        synthersizerHandler = nil
        synthesizer.delegate = nil
        request.finish()
        if activeRequest?.id == request.id {
            activeRequest = nil
        }
    }
}

private class SpeechSynthesizerRequestEventsHandler: NSObject, AVSpeechSynthesizerDelegate {
    init(request: TextToSpeechRequest,
                  completeHandlerQueue: DispatchQueue,
                  complete: @escaping (TextToSpeechRequest) -> Void) {
        self.request = request
        self.completeHandlerQueue = completeHandlerQueue
        self.complete = complete
    }

    let request: TextToSpeechRequest
    let completeHandlerQueue: DispatchQueue
    let complete: (TextToSpeechRequest) -> Void

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.start()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            guard let self = self else { return }
            self.complete(self.request)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.pause()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.continued()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completeHandlerQueue.async { [weak self] in
            self?.request.cancel()
        }
    }
}
