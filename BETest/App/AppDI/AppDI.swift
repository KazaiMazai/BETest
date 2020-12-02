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
    let store: Store
    let timeEventsDriver: Driver<TimeEventsOperator>
    let textToSpeechDriver: Driver<TextToSpeechOperator>
    let filename = "data.json"

    let fileDataSourceDriver: Driver<FileDataOperator>

    init() {
        let state = AppState()

        store = Store(initial: state) { state, action in
            defer { state.reduce(action) }
            print("Reduce: \t\t \(String(reflecting: action))")
        }

        theme = .defaultTheme
        environmentStore = EnvironmentStore(store: store)

        let timeEventsSideEffect = TimeEventsSideEffects()
        let timeEventsOperator = TimeEventsOperator()
        timeEventsDriver = Driver(store: store,
                                   sideEffectsOperator: timeEventsOperator,
                                   prepareRequests: timeEventsSideEffect.map)

        let fileDataSourceOperator = FileDataOperator()
        let fileDataSideEffects = FileDataSideEffects()
        fileDataSourceDriver = Driver(store: store,
                                sideEffectsOperator: fileDataSourceOperator,
                                prepareRequests: fileDataSideEffects.map)


        let ttsSideEffects = TTSSideEffects()
        let textToSpeechOperator = TextToSpeechOperator(queueLabel: "TTS Operator", qos: .userInitiated)
        textToSpeechDriver = Driver(store: store,
                                    sideEffectsOperator: textToSpeechOperator,
                                    prepareRequests: ttsSideEffects.map)

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
        store.subscribe(observer: timeEventsDriver.asObserver)
        store.subscribe(observer: fileDataSourceDriver.asObserver)
        store.subscribe(observer: textToSpeechDriver.asObserver)
    }

    private func rootViewWith<V: View>(view: V) -> some View {
        StoreProvidingView(store: environmentStore) {
            view.environment(\.appUITheme, theme)
        }
    }
}
