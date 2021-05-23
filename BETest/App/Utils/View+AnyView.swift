//
//  View+AnyView.swift
//  BETest
//
//  Created by Sergey Kazakov on 23.05.2021.
//

import SwiftUI

extension View {
    var eraseToAnyView: AnyView {
        AnyView(self)
    }
}
