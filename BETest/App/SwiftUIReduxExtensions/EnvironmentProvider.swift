//
//  EnvironmentProvider.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import SwiftUI

struct EnvironmentProvider<Content: View>: View {
    let store: EnvironmentStore
    let content: () -> Content
    
    var body: some View {
        content().injectEnvironment(store: store)
    }
}

private extension View {
    func injectEnvironment(store: EnvironmentStore) -> some View {
        self.environmentObject(store)
    }
}
