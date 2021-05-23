//
//  DialogueBinder.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI
import PureduxSwiftUI

struct DialoguePresenter: PresentableView {
    func content(for props: DialogueView.Props) -> DialogueView {
        DialogueView(props: props)
    }

    func props(for state: AppState, on store: EnvironmentStore<AppState, Action>) -> DialogueView.Props {
        DialogueView.Props(
            navBar: NavigationBarView.Props(title: "Dialogue"),
            items: balloonViewItemsProps(for: state),
            animationDuration: state.dialogue.animationsDelay,
            onAppear: store.bind(Actions.DialogueFlow.Run()))
    }

    var distinctStateChangesBy: Equating<AppState> {
        .equal {
            $0.dialogue.lastModified
        } &&
        .equal {
            $0.storage.lastModified
        }
    }
}

extension DialoguePresenter {
    private func dialogueMessageItems(for state: AppState) -> [DialogueMessage] {
        state.storage.messages.findAllById(state.dialogue.items)
    }

    private func balloonViewItemsProps(for state: AppState) -> [BallonView<Int>.Props<Int>] {
        dialogueMessageItems(for: state)
            .enumerated()
            .reversed()
            .map {
                BallonView.Props(
                    id: $0.offset,
                    text: $0.element.text)
            }
    }


}
