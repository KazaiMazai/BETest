//
//  DialogueView.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

extension DialogueView {
    struct Props {
        let navBar: NavigationBarView.Props
        let items: [BallonView<Int>.Props<Int>]
        let animationDuration: Double
        let onAppear: Command

        static func preview(count: Int) -> Props {
            Props(
                navBar: .preview,
                items: Array(0..<count).map { .preview(id: $0) },
                animationDuration: 0.5,
                onAppear: nop)
        }
    }
}

struct DialogueView: View {
    @Environment(\.appUITheme) var theme
    @State private var layoutWidth: CGFloat = 0
    
    let props: Props

    var body: some View {
        VStack(spacing: 0) {
            NavigationBarView(props: props.navBar)

            ScrollView {
                VStack(spacing: theme.baloonStyle.paddings.interItemSpacing) {
                    Color.clear.frame(height: 0)

                    ForEach(props.items, id: \.id) {
                        BallonView(props: $0, maxLayoutWidth: layoutWidth)
                            .rotationEffect(.radians(.pi))
                            .transition(itemTransitionForIndex($0.id))
                    }
                }
            }
            .animation(.linear(duration: props.animationDuration))
            .rotationEffect(.radians(.pi))
            .background(theme.dialogueViewStyle.backgroundColor)
            .edgesIgnoringSafeArea(.vertical)
        }
        .background(theme.navBarStyle.backgroundColor.edgesIgnoringSafeArea(.top))
        .onAppear { props.onAppear() }
        .disabled(true)
        .overlay(GeometryReader { geo in
            Color.clear.onAppear { layoutWidth = geo.size.width  }
        })
    }
}

struct DialogueView_Previews: PreviewProvider {
    static var previews: some View {
        DialogueView(props: .preview(count: 5))
    }
}

private extension DialogueView {
    func itemTransitionForIndex(_ idx: Int) -> AnyTransition {
        return idx == 0 ?
            AnyTransition.opacity
            : AnyTransition.move(edge: .top)
            .combined(with: .offset(x: 0, y: -theme.baloonStyle.paddings.interItemSpacing))
            .combined(with: .opacity)
    }
}
