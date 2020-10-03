//
//  FileDataSourceDriver.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import Foundation

struct FileDataSourceDriver {
    let store: Store<AppState, Action>
    let fileDataOperator: FileDataOperator
    private let jsonDecoder: JSONDecoder

    init(store: Store<AppState, Action>,
         fileDataOperator: FileDataOperator,
         decoder: JSONDecoder = FileDataSourceDriver.defaultDecoder) {

        self.store = store
        self.fileDataOperator = fileDataOperator
        self.jsonDecoder = decoder
    }

    var asObserver: Observer<AppState> {
        Observer(queue: self.fileDataOperator.completeHandlerQueue) { state in
            observe(state: state)
            return .active
        }
    }
}

extension FileDataSourceDriver {
    static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder

    }()
}

extension FileDataSourceDriver {
    private func observe(state: AppState) {
        guard let requestState = state.dialogue.dataRequestState else {
            fileDataOperator.process(requests: [])
            return
        }

        let request = loadDataRequestFor(requestState)
        fileDataOperator.process(requests: [request])
    }

    private func loadDataRequestFor(_ requestState: PayloadRequest<FileMetaData>) -> LoadDataRequest {
        LoadDataRequest(id: requestState.id,
                        filename: requestState.payload.filename) {
            switch $0 {
            case .success(let data):
                guard let itemsData = try? jsonDecoder.decode([FileTextData].self, from: data) else {
                    store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: Errors.couldNotDecodeData))
                    return
                }
                let models = itemsData.enumerated().map { TextData(id: $0.offset, text: $0.element.line) }
                store.dispatch(action: Actions.TextDataSource.ReceievedDataSuccess(value: models))
            case .failure(let error):
                store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: error))
            }
        }
    }
}

private struct FileTextData: Codable {
    let line: String
}

extension FileDataSourceDriver {
    enum Errors: Error {
        case couldNotDecodeData
    }
}
