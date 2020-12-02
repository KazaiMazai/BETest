//
//  Types.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI
import PureduxStore
import PureduxSideEffects
import PureduxSwiftUI

typealias EnvironmentStore = PureduxSwiftUI.EnvironmentStore<AppState, Action>

typealias Store = PureduxStore.Store<AppState, Action>
typealias Observer = PureduxStore.Observer<AppState>
typealias Driver<Operator> =
    PureduxSideEffects.Driver<Operator, AppState, Action> where Operator: OperatorProtocol
typealias Logger = PureduxSideEffects.Logger
typealias Loglevel = PureduxSideEffects.Loglevel
typealias ConsoleLogger = PureduxSideEffects.ConsoleLogger

typealias PresentingView = PureduxSwiftUI.PresentingView
typealias StoreProvidingView<Content: View> = PureduxSwiftUI.EnvironmentStoreProvidingView<AppState, Action, Content>

