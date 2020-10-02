//
//  DialogueView.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

extension DialogueView {
    struct Props {
        let items: [BallonView.Props]
        let animationDuration: CGFloat

        static func preview(count: Int) -> Props {
            .init(
                items: Array(0..<count).map { .preview(id: $0) },
                animationDuration: 0.5)
        }
    }
}

struct DialogueView: View {
    @Environment(\.appUITheme) var theme

    let props: Props

    var body: some View {
       makeBody
    }
}

struct DialogueView_Previews: PreviewProvider {
    static var previews: some View {
        DialogueView(props: .preview(count: 5))
    }
}


extension DialogueView {
    var makeBody: some View {
        ScrollView {
            VStack(spacing: theme.baloonStyle.paddings.interItemSpacing) {
                Color.clear.frame(height: 0)

                ForEach(props.items.reversed()) {
                    BallonView(props: $0).rotationEffect(.radians(.pi))
                }


            }
        }
        .rotationEffect(.radians(.pi))
        .ignoresSafeArea(edges: .vertical)
        .background(theme.dialogueViewStyle.background)
    }
}
