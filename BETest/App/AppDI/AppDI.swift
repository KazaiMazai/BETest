//
//  AppDI.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

struct AppDI {
    let theme: AppUITheme
    let environmentStore: EnvironmentStore
    let timeEventsEmitter: TimeEventsEmitter
    let textToSpeechDriver: TextToSpeechDriver
    let filename = "data.json"

    let fileDataSource: FileDataSourceDriver

    init() {
        let state = AppState()

        let store = Store<AppState, Action>(initial: state) { state, action in
            defer { state.reduce(action) }
            print("Reduce: \t\t \(String(reflecting: action))")
        }

        theme = .defaultTheme
        environmentStore = EnvironmentStore(store: store)
        timeEventsEmitter = TimeEventsEmitter(store: store, timeInterval: 1)


        let fileDataSourceOperator = FileDataOperator()
        fileDataSource = FileDataSourceDriver(store: store,
                                              fileDataOperator: fileDataSourceOperator)
        let textToSpeechOperator = TextToSpeechOperator()
        textToSpeechDriver = TextToSpeechDriver(store: store,
                                                textToSpeechOperator: textToSpeechOperator)

        subscribeToStore()
    }
}

extension AppDI {
    func launchUIWith(scene: UIScene) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else {
            return nil
        }

        let window = UIWindow(windowScene: windowScene)

        let rootView = rootViewWith(view: DialogueBinder())

        window.rootViewController = DarkHostingController(rootView: rootView)
        return window
    }
}

extension AppDI {
    private func subscribeToStore() {
        environmentStore.store.subscribe(observer: timeEventsEmitter.asObserver)
        environmentStore.store.subscribe(observer: fileDataSource.asObserver)
        environmentStore.store.subscribe(observer: textToSpeechDriver.asObserver)
    }

    private func rootViewWith<V: View>(view: V) -> some View {
        EnvironmentProvider(theme: theme,
                            store: environmentStore) { view }
    }
}
