//
//  DialogueBinder.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

struct DialogueBinder: UIBinder {
    func contentWith(props: DialogueView.Props) -> DialogueView {
        DialogueView(props: props)
    }

    func prepareProps(state: AppState, store: EnvironmentStore) -> DialogueView.Props {
        .init(items: state.prompter.items.map { .init(with: $0) },
              animationDuration: state.prompter.delay,
              onAppear: store.bind(Actions.PrompterFlow.Run()))
    }
}

extension BallonView.Props {
    init(with model: TextData) {
        self.init(id: model.id,
                  text: model.text)
    }
}
