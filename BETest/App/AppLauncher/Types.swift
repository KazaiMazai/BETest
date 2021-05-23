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

typealias EnvironmentStore = PureduxSwiftUI.EnvironmentStore
typealias Store = PureduxStore.Store<AppState, Action>
typealias Observer = PureduxStore.Observer<AppState>
typealias Middleware<Operator> =
    PureduxSideEffects.Middleware<AppState, Action, Operator> where Operator: OperatorProtocol
typealias Logger = PureduxSideEffects.Logger
typealias Loglevel = PureduxSideEffects.LogLevel
typealias ConsoleLogger = PureduxSideEffects.Logger

typealias PresentableView = PureduxSwiftUI.PresentableView 
typealias Equating = PureduxSwiftUI.Equating
typealias StoreProvidingView<Content: View> = PureduxSwiftUI.EnvironmentStoreProvidingView<AppState, Action, Content>

