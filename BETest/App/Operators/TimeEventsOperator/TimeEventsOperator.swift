//
//  TimeEventsOperator.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxSideEffects
import Foundation

extension DispatchWorkItem: OperatorTask { }

extension TimeEventsOperator {
    struct Request: OperatorRequest {
        let id: UUID
        let delay: Double
        let completeHandler: (TaskResult<Date, Void>) -> Void

        func handle(_ result: TaskResult<Date, Void>) {
            completeHandler(result)
        }
    }
}

class TimeEventsOperator: Operator<TimeEventsOperator.Request, DispatchWorkItem> {
    override init(label: String = "Time-Events-Operator",
                  qos: DispatchQoS = .utility,
                  logger: Logger = .console(.info)) {
        super.init(label: label, qos: qos, logger: logger)
    }
    
    override func run(task: DispatchWorkItem, for request: Request) {
        processingQueue.asyncAfter(deadline: .now() + request.delay, execute: task)
    }
    
    override func createTaskFor(_ request: TimeEventsOperator.Request,
                                with completeHandler: @escaping (TaskResult<Date, Void>) -> Void) -> DispatchWorkItem {
        
        DispatchWorkItem {
            completeHandler(.success(Date()))
        }
    }
}
