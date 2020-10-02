//
//  Reader.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct Dialogue {
    let delay: TimeInterval

    var animationsDelay: TimeInterval {
        delay
    }

    private var pendingItems: [TextData] = []
    private var state: State = .none

    private(set) var items: [TextData] = []

    init(delay: TimeInterval) {
        self.delay = delay
    }

    mutating func reduce(_ action: Action) {
        switch action {
        case is Actions.DialogueFlow.Run:
            state = .waitingForData
        case let action as Actions.TextDataSource.ReceievedDataSuccess:
            handleReceiveDataSuccess(action)
        case let action as Actions.SpeechSynthesizer.StateChange:
            handleSynthesizerStateChange(action)
        case let action as Actions.Time.TimeChanged:
            handleTimeChange(action)
        default:
            break
        }
    }
}

extension Dialogue {
    var waitingForData: Bool {
        guard case .waitingForData = state else {
            return false
        }

        return true
    }

    func availableForSpeech(at: Date) -> PayloadRequest<TextData>? {
        guard case let .processingItem(item, speechAvailableAfter) = state else {
            return nil
        }

        guard speechAvailableAfter <= at else {
            return nil
        }

        return item
    }
}

private extension Dialogue {
    mutating func handleReceiveDataSuccess(_ action: Actions.TextDataSource.ReceievedDataSuccess) {
        pendingItems.append(contentsOf: action.value)
        guard waitingForData && !pendingItems.isEmpty else {
            return
        }

        let item = pendingItems.removeFirst()
        state = .processingItem(PayloadRequest(id: UUID(), payload: item),
                                speechAvailableAfter: Date().addingTimeInterval(animationsDelay + delay))
        items.append(item)
    }

    mutating func handleSynthesizerStateChange(_ action: Actions.SpeechSynthesizer.StateChange) {
        guard case .finish = action.state else {
            return
        }

        guard !pendingItems.isEmpty else {
            return
        }

        let item = pendingItems.removeFirst()
        state = .pendingItem(item, availableAfter: Date().addingTimeInterval(delay))
    }

    mutating func handleTimeChange(_ action: Actions.Time.TimeChanged) {
        guard case let .pendingItem(item, availableAfter) = state else {
            return
        }

        guard availableAfter <= action.timestamp else {
            return
        }

        state = .processingItem(PayloadRequest(id: UUID(), payload: item),
                                speechAvailableAfter: Date().addingTimeInterval(animationsDelay + delay))
        items.append(item)
    }
}

private extension Dialogue {
    enum State {
        case none
        case waitingForData
        case pendingItem(TextData, availableAfter: Date)
        case processingItem(PayloadRequest<TextData>, speechAvailableAfter: Date)
        case finished
    }
}
