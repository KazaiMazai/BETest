//
//  AppDI.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

struct AppDI {
    let store: Store<AppState, Action>
    let envStore: EnvironmentStore

    let timeEventsEmitter: TimeEventsEmitter

    init() {
        let state = AppState()

        store = Store(initial: state) { state, action in
            defer { state.reduce(action) }
            print("Reduce: \t\t \(String(reflecting: action))")
        }

        envStore = EnvironmentStore(store: store)
        timeEventsEmitter = TimeEventsEmitter(store: store, timeInterval: 1)

        subscribeToStore()
    }

    fileprivate func subscribeToStore() {
        store.subscribe(observer: timeEventsEmitter.asObserver)
    }

    fileprivate func rootViewWith<V: View>(view: V) -> some View {
        EnvironmentProvider(store: envStore) { view }
    }

    func launchUIWith(scene: UIScene) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else {
            return nil
        }

        let window = UIWindow(windowScene: windowScene)

        let rootView = rootViewWith(view: ContentView())

        window.rootViewController = UIHostingController(rootView: rootView)
        return window
    }
}
