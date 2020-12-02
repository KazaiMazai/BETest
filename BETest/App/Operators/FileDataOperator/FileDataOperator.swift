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
        func handle(_ result: OperatorResult<Data>) {
            switch result {
            case .success(let data):
                complete(.success(data))
            case .error(let error):
                complete(.failure(error))
            case .cancelled:
                break
            }
        }
        
        let id: UUID
        let filename: String
        let complete: CommandWith<Result<Data, Error>>
    }
}

class FileDataOperator: Operator<FileDataOperator.Request, DispatchWorkItem> {
    public override init(queueLabel: String = "File-Data-Operator",
                         qos: DispatchQoS = .utility,
                         logging: LogSource = LogSource.defaultLogging()) {
        super.init(queueLabel: queueLabel, qos: qos, logging: logging)
    }
    
    override func run(task: DispatchWorkItem, for request: FileDataOperator.Request) {
        queue.async(execute: task)
    }
    
    override func createTaskFor(_ request: Request, with completeHandler: @escaping (OperatorResult<Data>) -> Void) -> DispatchWorkItem {
        DispatchWorkItem {
            let name = String(request.filename.split(separator: ".").first ?? "")
            let fileExtension = String(request.filename.split(separator: ".").last ?? "")
            
            
            guard let filePath = Bundle.main.url(forResource: name,
                                                 withExtension: fileExtension) else {
                
                completeHandler(.error(Errors.couldNotOpenFile))
                return
            }
            
            guard let stringContent = try? String(contentsOfFile: filePath.path, encoding: .utf8) else {
                completeHandler(.error(Errors.couldNotOpenFile))
                return
            }
            
            guard let contentData = stringContent.data(using: .utf8) else {
                completeHandler(.error(Errors.unrecognizedDataFormat))
                return
            }
            
            completeHandler(.success(contentData))
        }
    }
}

private extension FileDataOperator {
    enum Errors: Error {
        case couldNotOpenFile
        case unrecognizedDataFormat
    }
}
