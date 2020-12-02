//
//  UIBinder.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI
/*
protocol PresentingView: View {
    associatedtype Content: View
    associatedtype Props

    func contentWith(props: Props) -> Content
    func prepareProps(state: AppState, store: EnvironmentStore) -> Props
}

extension PresentingView {
    private func map(state: AppState, store: EnvironmentStore) -> Content {
        contentWith(props: prepareProps(state: state, store: store))
    }

    var body: some View {
        UIBind<Content>(map: map)
    }
}

private struct UIBind<V: View>: View {
    @EnvironmentObject var store: EnvironmentStore

    let map: (_ state: AppState, _ store: EnvironmentStore) -> V

    var body: V {
        map(store.state, store)
    }
}
*/
