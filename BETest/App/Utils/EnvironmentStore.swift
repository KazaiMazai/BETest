//
//  File.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

extension EnvironmentStore {
    func bind(_ action: Action) -> Command {
        return {
            self.dispatch(action)
        }
    }

    func bind<T>(_ action: @escaping (T) -> Action) -> CommandWith<T> {
        return { value in
            self.dispatch(action(value))
        }
    }
}
