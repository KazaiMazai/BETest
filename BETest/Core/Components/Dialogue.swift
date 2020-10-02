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
            pendingItems.append(contentsOf: action.value)
            guard waitingForData && !pendingItems.isEmpty else {
                break
            }

            let item = pendingItems.removeFirst()
            state = .processingItem(PayloadRequest(id: UUID(), payload: item),
                                    speechAvailableAfter: Date().addingTimeInterval(animationsDelay + delay))
            items.append(item)
        case let action as Actions.SpeechSynthesizer.StateChange:
            guard case .finish = action.state else {
                break
            }

            guard !pendingItems.isEmpty else {
                break
            }

            let item = pendingItems.removeFirst()
            state = .pendingItem(item, availableAfter: Date().addingTimeInterval(delay))
        case let action as Actions.Time.TimeChanged:
            guard case let .pendingItem(item, availableAfter) = state else {
                break
            }

            guard availableAfter <= action.timestamp else {
                break
            }

            state = .processingItem(PayloadRequest(id: UUID(), payload: item),
                                    speechAvailableAfter: Date().addingTimeInterval(animationsDelay + delay))
            items.append(item)
        default:
            break
        }
    }
}

extension Dialogue {
    enum State {
        case none
        case waitingForData
        case pendingItem(TextData, availableAfter: Date)
        case processingItem(PayloadRequest<TextData>, speechAvailableAfter: Date)
        case finished
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
