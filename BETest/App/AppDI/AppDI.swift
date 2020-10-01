//
//  AppDI.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

struct AppDI {
    let environmentStore: EnvironmentStore
    let timeEventsEmitter: TimeEventsEmitter

    init() {
        let state = AppState()

        let store = Store<AppState, Action>(initial: state) { state, action in
            defer { state.reduce(action) }
            print("Reduce: \t\t \(String(reflecting: action))")
        }

        environmentStore = EnvironmentStore(store: store)
        timeEventsEmitter = TimeEventsEmitter(store: store, timeInterval: 1)

        subscribeToStore()
    }
}

extension AppDI {
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

extension AppDI {
    private func subscribeToStore() {
        environmentStore.store.subscribe(observer: timeEventsEmitter.asObserver)
    }

    private func rootViewWith<V: View>(view: V) -> some View {
        EnvironmentProvider(store: environmentStore) { view }
    }
}
