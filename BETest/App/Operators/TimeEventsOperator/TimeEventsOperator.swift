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
    public struct Request: OperatorRequest {
        func handle(_ result: OperatorResult<Date>) {
            switch result {
            case .success(let res):
                handler(.success(res))
            case .cancelled:
                handler(.cancelled)
            case .error(let error):
                handler(.error(error))
            }
        }

        public init(id: UUID,
                    delay: Double,
                    handler: @escaping (OperatorResult<Date>) -> Void) {
            self.id = id
            self.delay = delay
            self.handler = handler
        }

        let id: UUID
        let delay: Double
        let handler: (OperatorResult<Date>) -> Void
    }
}

class TimeEventsOperator: Operator<TimeEventsOperator.Request, DispatchWorkItem> {
    public override init(queueLabel: String = "Time-Events-Operator",
                         qos: DispatchQoS = .utility,
                logging: LogSource = LogSource.defaultLogging()) {
        super.init(queueLabel: queueLabel, qos: qos, logging: logging)
    }

    override func run(task: DispatchWorkItem, for request: Request) {
        queue.asyncAfter(deadline: .now() + request.delay, execute: task)
    }

    override func createTaskFor(_ request: TimeEventsOperator.Request,
                                with completeHandler: @escaping (OperatorResult<Date>) -> Void) -> DispatchWorkItem {

        DispatchWorkItem {
            completeHandler(.success(Date()))
        }
    }
}
