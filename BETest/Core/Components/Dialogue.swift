//
//  Reader.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

struct Dialogue {
    private let delay: TimeInterval
    private var state: State = .none

    private(set) var lastModified: Date = .distantPast
    private(set) var pendingItems: [DialogueMessage.ID] = []
    private(set) var items: [DialogueMessage.ID] = []
    private let dataFileName: String

    init(delay: TimeInterval, dataFileName: String) {
        self.dataFileName = dataFileName
        self.delay = delay
    }
}

// MARK: - Dialogue Reducer

extension Dialogue {
    mutating func reduce(_ action: Action, env: AppEnvironment) {
        switch action {
        case is Actions.DialogueFlow.Run:
            lastModified = env.now()
            requestLoadDataFrom(filename: dataFileName, requestId: env.makeUUID())

        case let action as Actions.TextDataSource.ReceievedDataSuccess:
            lastModified = env.now()
            processNewTextData(data: action.value.map { $0.id })

        case let action as Actions.SpeechSynthesizer.StateChange:
            lastModified = env.now()
            handleSpeakingStateChange(action.state)

        case is Actions.Time.TimeChanged:
            lastModified = env.now()
            startSpeakingIfReady(now: env.now())

        default:
            break
        }
    }
}

// MARK: - Dialogue API

extension Dialogue {
    var animationsDelay: TimeInterval {
        delay
    }

    var isWaitingForData: Bool {
        dataRequestState != nil
    }

    var dataRequestState: PayloadRequest<FileMetaData>? {
        guard case let .waitingForData(request) = state else {
            return nil
        }

        return request
    }

    func availableForSpeech(at: Date) -> PayloadRequest<DialogueMessage.ID>? {
        guard case let .speakingItem(item, speechAvailableAfter) = state else {
            return nil
        }

        guard speechAvailableAfter <= at else {
            return nil
        }

        return item
    }
}

// MARK: - Dialogue Private

extension Dialogue {
    private mutating func requestLoadDataFrom(filename: String, requestId: UUID) {
        state = .waitingForData(
            PayloadRequest(
                id: requestId,
                payload: FileMetaData(filename: filename)))
    }

    private mutating func processNewTextData(data: [DialogueMessage.ID]) {
        pendingItems.append(contentsOf: data)
        guard isWaitingForData && !pendingItems.isEmpty else {
            return
        }

        let item = pendingItems.removeFirst()
        state = .speakingItem(PayloadRequest(id: UUID(), payload: item),
                                speechAvailableAfter: Date().addingTimeInterval(animationsDelay + delay))
        items.append(item)
    }

    private mutating func handleSpeakingStateChange(_ state: SyntesizerState) {
        guard case .finish = state else {
            return
        }

        guard !pendingItems.isEmpty else {
            return
        }

        let item = pendingItems.removeFirst()
        self.state = .pendingItem(item, availableAfter: Date().addingTimeInterval(delay))
    }

    private mutating func startSpeakingIfReady(now: Date) {
        guard case let .pendingItem(item, availableAfter) = state else {
            return
        }

        guard now >= availableAfter else {
            return
        }

        state = .speakingItem(PayloadRequest(
                                    id: UUID(),
                                    payload: item),
                                speechAvailableAfter: now.addingTimeInterval(animationsDelay + delay))
        items.append(item)
    }
}

private extension Dialogue {
    enum State {
        case none
        case waitingForData(PayloadRequest<FileMetaData>)
        case pendingItem(DialogueMessage.ID, availableAfter: Date)
        case speakingItem(PayloadRequest<DialogueMessage.ID>, speechAvailableAfter: Date)
        case finished
    }
}
