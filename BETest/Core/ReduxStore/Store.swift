//
//  Store.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Dispatch

class Store<State, Action> {
    typealias Reducer = (inout State, Action) -> Void
    private(set) var state: State
    let reducer: Reducer

    private let queue = DispatchQueue(label: "Store queue", qos: .userInitiated)
    private var observers: Set<Observer<State>> = []

    init(initial state: State, reducer: @escaping Reducer) {
        self.reducer = reducer
        self.state = state
    }

    private func notify(_ observer: Observer<State>) {
        let status = observer.queue.sync {
            observer.observe(state)
        }

        if case .dead = status {
            observers.remove(observer)
        }
    }
}

extension Store {
    func subscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.observers.insert(observer)
            self.notify(observer)
        }
    }

    func dispatch(action: Action) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.reducer(&self.state, action)
            self.observers.forEach(self.notify)
        }
    }

}
