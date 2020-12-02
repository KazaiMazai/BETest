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
    let timeEventsEmitter: Driver<TimeEventsOperator>
    let textToSpeechDriver: Driver<TextToSpeechOperator>
    let filename = "data.json"

//    let fileDataSource: FileDataSourceDriver

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
        timeEventsEmitter = Driver(store: store,
                                   sideEffectsOperator: timeEventsOperator,
                                   prepareRequests: timeEventsSideEffect.map)
//
//        let fileDataSourceOperator = FileDataOperator()
//        fileDataSource = FileDataSourceDriver(store: store,
//                                              fileDataOperator: fileDataSourceOperator)


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
        store.subscribe(observer: timeEventsEmitter.asObserver)
//        store.subscribe(observer: fileDataSource.asObserver)
        store.subscribe(observer: textToSpeechDriver.asObserver)
    }

    private func rootViewWith<V: View>(view: V) -> some View {
        EnvironmentProvider(theme: theme,
                            store: environmentStore) { view }
    }
}
