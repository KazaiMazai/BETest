//
//  AppDI.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

struct AppLauncher {
    private let theme: AppUITheme
    private let screenViewsFactory: ScreenViewsFactoryProtocol
    private let environmentStore: EnvironmentStore<AppState, Action>
    private let store: Store
    private let appStateEnvironment: AppEnvironment
    private let appStateConfig: AppStateConfig

    private let timeEvents: Middleware<TimeEventsOperator>
    private let textToSpeech: Middleware<TextToSpeechOperator>
    private let readFileData: Middleware<FileDataOperator>

    init() {
        let env = AppEnvironment.defaultAppEnvironment()
        let config = AppStateConfig.defaultConfig()
        let initialState = AppState.createStateWith(config: config, env: env)
        let reducerLogger: Logger = .with(label: "Reducer", logger: .console(.debug))

        store = Store(initial: initialState) { state, action in
            reducerLogger.log(.debug, "\(String(reflecting: action))")
            state.reduce(action, env: env)
        }

        environmentStore = EnvironmentStore(store: store)
        appStateEnvironment = env
        appStateConfig = config
        theme = AppUITheme.defaultTheme
        screenViewsFactory = ScreenViewsFactory.defaultScreenViewsFactory

        timeEvents = Middleware(
            store: store,
            operator: TimeEventsOperator(
                label: "TimeEvents Operator",
                qos: .background,
                logger: .console(.silent)),
            props: TimeEventsSideEffects().props)

        readFileData = Middleware(
            store: store,
            operator: FileDataOperator(
                label: "FileData Operator",
                qos: .background,
                logger: .console(.debug)),
            props: FileDataSideEffects().props)

        textToSpeech = Middleware(
            store: store,
            operator: TextToSpeechOperator(
                label: "TTS Operator",
                qos: .userInitiated,
                logger: .console(.debug)),
            props: TextToSpeechSideEffects().props)
    }
}

extension AppLauncher {
    func launchUIWith(scene: UIScene) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else {
            return nil
        }

        let window = UIWindow(windowScene: windowScene)
        let rootView = rootViewWith(view: screenViewsFactory.makeView(for: .dialogue))
        window.rootViewController = DarkHostingController(rootView: rootView)
        return window
    }

    func run() {
        subscribeToStore()
    }
}

private extension AppLauncher {
    func subscribeToStore() {
        store.subscribe(observer: timeEvents.asObserver)
        store.subscribe(observer: readFileData.asObserver)
        store.subscribe(observer: textToSpeech.asObserver)
    }

    func rootViewWith<V: View>(view: V) -> some View {
        StoreProvidingView(store: environmentStore) {
            view.environment(\.appUITheme, theme)
                .environment(\.screenViewsFactory, self.screenViewsFactory)
        }
    }
}
