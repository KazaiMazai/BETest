//
//  TimeEventEmitter.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

class TimeEventsEmitter {
    let store: Store<AppState, Action>

    private let queue: DispatchQueue
    private var timer: Timer?
    private let timeInterval: TimeInterval

    init(store: Store<AppState, Action>,
                timeInterval: TimeInterval,
                queue: DispatchQueue = .main) {

        self.store = store
        self.timeInterval = timeInterval
        self.queue = queue
        self.timer = nil
    }

    var asObserver: Observer<AppState> {
        Observer(queue: self.queue) { [weak self] state in
            self?.observe(state: state)
            return .active
        }
    }

    fileprivate func observe(state: AppState) {
        guard state.currentTime.shouldReceiveTimeEvents else {
            timer?.invalidate()
            timer = nil
            return
        }

        guard timer != nil else {
            timer = Timer.scheduledTimer(withTimeInterval: timeInterval,
                                         repeats: true,
                                         block: { [weak self] (_) in
                self?.store.dispatch(action: Actions.Time.TimeChanged(timestamp: Date()))
            })

            return
        }
    }
}
