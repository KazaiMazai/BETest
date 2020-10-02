//
//  TextDataSource.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation

class FileDataSource {
    let store: Store<AppState, Action>
    let filename: String
    private let completeHandlerQueue: DispatchQueue
    private let jsonDecoder: JSONDecoder
    private var inProgress: Bool = false

    init(store: Store<AppState, Action>,
         completeHandlerQueue: DispatchQueue = DispatchQueue(label: "FileDataSource"),
         filename: String,
         decoder: JSONDecoder = FileDataSource.defaultDecoder) {

        self.store = store
        self.completeHandlerQueue = completeHandlerQueue
        self.filename = filename
        self.jsonDecoder = decoder
    }

    var asObserver: Observer<AppState> {
        Observer(queue: self.completeHandlerQueue) { [weak self] state in
            self?.observe(state: state)
            return .active
        }
    }
}

extension FileDataSource {
    static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder

    }()
}

extension FileDataSource {
    private func observe(state: AppState) {
        guard state.dialogue.waitingForData else{
            return
        }

        guard !inProgress else {
            return
        }

        inProgress = true

        print("FileDataSource:\t\t ReadFile: \(filename) \n")

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.read()
        }
    }

    private func read() {
        let name = String(filename.split(separator: ".").first ?? "")
        let fileExtension = String(filename.split(separator: ".").last ?? "")

        guard let filePath = Bundle.main.url(forResource: name,
                                             withExtension: fileExtension) else {
            store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: Errors.couldNotOpenFile))
            return
        }

        guard let stringContent = try? String(contentsOfFile: filePath.path, encoding: .utf8) else {
            store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: Errors.couldNotOpenFile))
            return
        }

        guard let contentData = stringContent.data(using: .utf8) else {
            store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: Errors.unrecognizedDataFormat))
            return
        }

        guard let data = try? jsonDecoder.decode([FileTextData].self, from: contentData) else {
            store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: Errors.unrecognizedDataFormat))
            return
        }

        let models = data.enumerated().map { TextData(id: $0.offset, text: $0.element.line) }

        completeHandlerQueue.async { [weak self] in
            self?.store.dispatch(action: Actions.TextDataSource.ReceievedDataSuccess(value: models))
        }

    }
}

private struct FileTextData: Codable {
    let line: String
}


private extension FileDataSource {
    enum Errors: Error {
        case couldNotOpenFile
        case unrecognizedDataFormat
    }
}
