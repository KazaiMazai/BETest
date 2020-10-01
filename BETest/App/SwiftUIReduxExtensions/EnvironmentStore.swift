//
//  File.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

class EnvironmentStore: ObservableObject {
    let store: Store<AppState, Action>

    @Published private (set) var state: AppState

    init(store: Store<AppState, Action>) {
        self.store = store
        self.state = store.state

        store.subscribe(observer: asObserver)
    }

    func dispatch(_ action: Action) {
        store.dispatch(action: action)
    }

    private var asObserver: Observer<AppState> {
        Observer(queue: .main) { state in
            self.state = state
            return .active
        }
    }

    func bind(_ action: Action) -> Command {
        return {
            self.dispatch(action)
        }
    }

    func bind<T>(_ action: @escaping (T) -> Action) -> CommandWith<T> {
        return { value in
            self.dispatch(action(value))
        }
    }
}
