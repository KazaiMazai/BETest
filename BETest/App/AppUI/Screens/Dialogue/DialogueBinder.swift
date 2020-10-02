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
              animationDuration: CGFloat(state.prompter.delay),
              onAppear: store.bind(Actions.PrompterFlow.Run()))
    }
}

struct DialogueBinder_Previews: PreviewProvider {
    static var previews: some View {
        DialogueBinder()
    }
}

extension BallonView.Props {
    init(with model: TextData) {
        self.init(id: model.id,
                  text: model.text)
    }
}
