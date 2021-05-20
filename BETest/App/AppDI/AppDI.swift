//
//  AppDI.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

struct AppDI {
    let theme: AppUITheme
    let environmentStore: EnvironmentStore<AppState, Action>
    let store: Store
    let timeEvents: Middleware<TimeEventsOperator>
    let textToSpeech: Middleware<TextToSpeechOperator>
    let filename = "data.json"

    let fileDataSourceDriver: Middleware<FileDataOperator>

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
        timeEvents = Middleware(store: store,
                                operator: timeEventsOperator,
                                props: timeEventsSideEffect.map)

        let fileDataSourceOperator = FileDataOperator()
        let fileDataSideEffects = FileDataSideEffects()
        fileDataSourceDriver = Middleware(store: store,
                                          operator: fileDataSourceOperator,
                                          props: fileDataSideEffects.map)


        let ttsSideEffects = TextToSpeechSideEffects()
        let textToSpeechOperator = TextToSpeechOperator(label: "TTS Operator",
                                                        qos: .userInitiated)
        textToSpeech = Middleware(store: store,
                                  operator: textToSpeechOperator,
                                  props: ttsSideEffects.map)

        subscribeToStore()
    }
}

extension AppDI {
    func launchUIWith(scene: UIScene) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else {
            return nil
        }

        let window = UIWindow(windowScene: windowScene)

        let rootView = rootViewWith(view: DialoguePresenter())

        window.rootViewController = DarkHostingController(rootView: rootView)
        return window
    }
}

extension AppDI {
    private func subscribeToStore() {
        store.subscribe(observer: timeEvents.asObserver)
        store.subscribe(observer: fileDataSourceDriver.asObserver)
        store.subscribe(observer: textToSpeech.asObserver)
    }

    private func rootViewWith<V: View>(view: V) -> some View {
        StoreProvidingView(store: environmentStore) {
            view.environment(\.appUITheme, theme)
        }
    }
}
