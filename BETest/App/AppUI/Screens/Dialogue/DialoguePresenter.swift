//
//  DialogueBinder.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

struct DialoguePresenter: PresentableView {
    var stateEquating: Equating<AppState> {
        .equal {
            $0.dialogue.lastModified
        }
    }

    func content(for props: DialogueView.Props) -> DialogueView {
        DialogueView(props: props)
    }

    func props(for state: AppState, on store: EnvironmentStore<AppState, Action>) -> DialogueView.Props {
        DialogueView.Props(
            title: "Dialogue",
            items: state.dialogue.items.map { BallonView.Props(
                id: $0.id.rawValue,
                text: $0.text) },
            animationDuration: state.dialogue.animationsDelay,
            onAppear: store.bind(Actions.DialogueFlow.Run()))
    }
}
