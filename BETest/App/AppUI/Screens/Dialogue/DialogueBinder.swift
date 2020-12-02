//
//  DialogueBinder.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

struct DialogueBinder: PresentingView {
    func map(props: DialogueView.Props) -> DialogueView {
        DialogueView(props: props)
    }


    func props(for state: AppState, on store: EnvironmentStore) -> DialogueView.Props {
        .init(title: "Dialogue",
              items: state.dialogue.items.map { .init(with: $0) },
              animationDuration: state.dialogue.animationsDelay,
              onAppear: store.bind(Actions.DialogueFlow.Run(filename: "data.json")))
    }
}

extension BallonView.Props {
    init(with model: TextData) {
        self.init(id: model.id,
                  text: model.text)
    }
}
