//
//  FileDataOperator.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import Foundation

class FileDataOperator {
    let completeHandlerQueue: DispatchQueue

    private var activeRequests: [UUID: LoadDataRequest] = [:]
    private var completedRequests: Set<UUID> = []

    init(completeHandlerQueue: DispatchQueue = DispatchQueue(label: "FileDataSource operator")) {
        self.completeHandlerQueue = completeHandlerQueue
    }

    func process(requests: [LoadDataRequest]) {
        var remainedActiveRequestsIds = Set(activeRequests.keys)

        for request in requests {
            process(request: request)
            remainedActiveRequestsIds.remove(request.id)
        }
    }

    private func process(request: LoadDataRequest) {
        if completedRequests.contains(request.id) {
            return
        }

        guard !activeRequests.keys.contains(request.id) else {
            return
        }

        print("FileDataOperator:\t\t id: \(request.id) filename: \(request.filename) \n")

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.performRead(request: request)
        }
    }


    private func performRead(request: LoadDataRequest) {
        let name = String(request.filename.split(separator: ".").first ?? "")
        let fileExtension = String(request.filename.split(separator: ".").last ?? "")

        let complete = { [weak self] in
            guard let self = self else { return }

            self.completedRequests.insert(request.id)
            self.activeRequests[request.id] = nil
        }

        guard let filePath = Bundle.main.url(forResource: name,
                                             withExtension: fileExtension) else {
            completeHandlerQueue.async {
                complete()
                request.complete(.failure(Errors.couldNotOpenFile))
            }

            return
        }

        guard let stringContent = try? String(contentsOfFile: filePath.path, encoding: .utf8) else {
            completeHandlerQueue.async {
                complete()
                request.complete(.failure(Errors.couldNotOpenFile))
            }

            return
        }

        guard let contentData = stringContent.data(using: .utf8) else {
            completeHandlerQueue.async {
                complete()
                request.complete(.failure(Errors.unrecognizedDataFormat))
            }
            return
        }

        completeHandlerQueue.async {
            complete()
            request.complete(.success(contentData))
        }
    }
}


private extension FileDataOperator {
    enum Errors: Error {
        case couldNotOpenFile
        case unrecognizedDataFormat
    }
}
