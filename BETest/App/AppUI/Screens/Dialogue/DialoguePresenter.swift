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
            navBar: NavigationBarView.Props(title: "Dialogue"),
            items: state.dialogue.items
                .enumerated()
                .reversed()
                .map {
                    BallonView.Props(
                        id: $0.offset,
                        text: $0.element.text)
                },
            animationDuration: state.dialogue.animationsDelay,
            onAppear: store.bind(Actions.DialogueFlow.Run()))
    }
}
