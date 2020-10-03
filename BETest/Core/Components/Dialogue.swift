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

    private(set) var pendingItems: [TextData] = []
    private var state: State = .none

    private(set) var items: [TextData] = []

    init(delay: TimeInterval) {
        self.delay = delay
    }

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as Actions.DialogueFlow.Run:
            state = .waitingForData(RequestState(id: UUID(), payload: FileMetaData(filename: action.filename)))
        case let action as Actions.TextDataSource.ReceievedDataSuccess:
            pendingItems.append(contentsOf: action.value.filter { !$0.text.isEmpty })
            guard isWaitingForData && !pendingItems.isEmpty else {
                break
            }

            let item = pendingItems.removeFirst()
            state = .processingItem(RequestState(id: UUID(), payload: item),
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

            state = .processingItem(RequestState(id: UUID(), payload: item),
                                    speechAvailableAfter: Date().addingTimeInterval(animationsDelay + delay))
            items.append(item)
        default:
            break
        }
    }
}

extension Dialogue {
    var isWaitingForData: Bool {
        dataRequestState != nil
    }

    var dataRequestState: RequestState<FileMetaData>? {
        guard case let .waitingForData(request) = state else {
            return nil
        }

        return request
    }

    func availableForSpeech(at: Date) -> RequestState<TextData>? {
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
    enum State {
        case none
        case waitingForData(RequestState<FileMetaData>)
        case pendingItem(TextData, availableAfter: Date)
        case processingItem(RequestState<TextData>, speechAvailableAfter: Date)
        case finished
    }
}
