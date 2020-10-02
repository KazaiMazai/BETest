//
//  TextDataSource.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import Foundation

class FileDataSource {
    let store: Store<AppState, Action>
    private let queue: DispatchQueue

    init(store: Store<AppState, Action>,
         queue: DispatchQueue = DispatchQueue.global(qos: .background)) {

        self.store = store
        self.queue = queue
    }

    var asObserver: Observer<AppState> {
        Observer(queue: self.queue) { [weak self] state in
            self?.observe(state: state)
            return .active
        }
    }
}

extension FileDataSource {
    private func observe(state: AppState) {
        guard state.prompter.waitingForData else{
            return
        }

        let data = Array(0...10).map { TextData(id: $0, text: "\($0): Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum")}

        store.dispatch(action: Actions.TextDataSource.ReceievedDataSuccess(value: data))
    }
}
