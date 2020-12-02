//
//  TimeEventEmitter.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation
import PureduxSideEffects

struct TimeEventsSideEffects {
    func map(state: AppState, on store: Store) -> [TimeEventsOperator.Request] {
        guard case let .inProgress(requestState) = state.currentTime.request else {
            return []
        }
        
        let request = TimeEventsOperator.Request(id: requestState.id,
                                                 delay: state.currentTime.interval) {
            switch $0 {
            case .success(let date):
                store.dispatch(action: Actions.Time.TimeChanged(timestamp: date))
            case .cancelled:
                break
            case .error:
                break
            }
        }
        
        return [request]
    }
}
