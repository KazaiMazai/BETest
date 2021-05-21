//
//  FileDataOperator.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import Foundation
import PureduxSideEffects

extension FileDataOperator {
    struct Request: OperatorRequest {
        let id: UUID
        let filename: String
        let completeHandler: (TaskResult<Data, Void>) -> Void

        func handle(_ result: TaskResult<Data, Void>) {
            completeHandler(result)
        }
    }
}

class FileDataOperator: Operator<FileDataOperator.Request, DispatchWorkItem> {
    override init(label: String = "File-Data-Operator",
                         qos: DispatchQoS = .utility,
                         logger: Logger = .console(.info)) {
        super.init(label: label, qos: qos, logger: logger)
    }
    
    override func run(task: DispatchWorkItem, for request: FileDataOperator.Request) {
        processingQueue.async(execute: task)
    }
    
    override func createTaskFor(_ request: Request,
                                with taskResultHandler: @escaping (TaskResult<Data, Void>) -> Void) -> DispatchWorkItem {
        DispatchWorkItem {
            let name = String(request.filename.split(separator: ".").first ?? "")
            let fileExtension = String(request.filename.split(separator: ".").last ?? "")
            
            
            guard let filePath = Bundle.main.url(forResource: name,
                                                 withExtension: fileExtension) else {
                
                taskResultHandler(.failure(Errors.couldNotOpenFile))
                return
            }
            
            guard let stringContent = try? String(contentsOfFile: filePath.path, encoding: .utf8) else {
                taskResultHandler(.failure(Errors.couldNotOpenFile))
                return
            }
            
            guard let contentData = stringContent.data(using: .utf8) else {
                taskResultHandler(.failure(Errors.unrecognizedDataFormat))
                return
            }
            
            taskResultHandler(.success(contentData))
        }
    }
}

private extension FileDataOperator {
    enum Errors: Error {
        case couldNotOpenFile
        case unrecognizedDataFormat
    }
}
