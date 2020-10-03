//
//  Store.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Dispatch

class Observer<State>: Hashable {
    enum Status {
        case active
        case dead
    }

    let queue: DispatchQueue
    let observe: (State) -> Status

    init(queue: DispatchQueue, observe: @escaping (State) -> Status) {
        self.queue = queue
        self.observe = observe
    }


    static func == (lhs: Observer<State>, rhs: Observer<State>) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}
