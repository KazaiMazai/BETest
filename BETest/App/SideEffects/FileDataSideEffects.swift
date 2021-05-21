//
//  FileDataSourceDriver.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import Foundation

struct FileDataSideEffects {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = Self.defaultDecoder) {
        self.decoder = decoder
    }
    
    enum Errors: Error {
        case couldNotDecodeData
    }
    
    static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
        
    }()
    
    func map(state: AppState, on store: Store) -> [FileDataOperator.Request] {
        guard let requestState = state.dialogue.dataRequestState else {
            return []
        }
        
        let request = FileDataOperator.Request(id: requestState.id,
                                               filename: requestState.payload.filename) {
            switch $0 {
            case .success(let data):
                guard let itemsData = try? decoder.decode([FileTextData].self, from: data) else {
                    store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: Errors.couldNotDecodeData))
                    return
                }
                
                let models = itemsData
                    .enumerated()
                    .map { TextData(
                        id: TextData.ID(rawValue: $0.offset),
                        text: $0.element.line) }
                store.dispatch(action: Actions.TextDataSource.ReceievedDataSuccess(value: models))
            case .failure(let error):
                store.dispatch(action: Actions.TextDataSource.ReceievedDataFail(error: error))
            case .cancelled:
                break
            case .statusChanged:
                break
            }
        }
        
        return [request]
    }
}

private struct FileTextData: Codable {
    let line: String
}
