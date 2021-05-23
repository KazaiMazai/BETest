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
    let appStateEnvironment: AppEnvironment
    let appStateConfig: AppStateConfig

    let timeEvents: Middleware<TimeEventsOperator>
    let textToSpeech: Middleware<TextToSpeechOperator>
    let readFileData: Middleware<FileDataOperator>

    init() {
        let env = AppEnvironment.defaultAppEnvironment()
        let config = AppStateConfig.defaultConfig()
        let initialState = AppState.createStateWith(config: config, env: env)

        store = Store(initial: initialState) { state, action in
            print("[Reducer] \(String(reflecting: action))")
            state.reduce(action, env: env)
        }

        theme = .defaultTheme
        environmentStore = EnvironmentStore(store: store)
        appStateEnvironment = env
        appStateConfig = config

        let timeEventsSideEffect = TimeEventsSideEffects()
        let timeEventsOperator = TimeEventsOperator()
        timeEvents = Middleware(
            store: store,
            operator: timeEventsOperator,
            props: timeEventsSideEffect.map)

        let fileDataSourceOperator = FileDataOperator()
        let fileDataSideEffects = FileDataSideEffects()
        readFileData = Middleware(
            store: store,
            operator: fileDataSourceOperator,
            props: fileDataSideEffects.map)


        let ttsSideEffects = TextToSpeechSideEffects()
        let textToSpeechOperator = TextToSpeechOperator(
            label: "TTS Operator",
            qos: .userInitiated)
        textToSpeech = Middleware(
            store: store,
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
        store.subscribe(observer: readFileData.asObserver)
        store.subscribe(observer: textToSpeech.asObserver)
    }

    private func rootViewWith<V: View>(view: V) -> some View {
        StoreProvidingView(store: environmentStore) {
            view.environment(\.appUITheme, theme)
        }
    }
}
