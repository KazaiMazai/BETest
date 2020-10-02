//
//  BallonView.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

extension BallonView {
    struct Props: Identifiable {
        let id: Int
        let text: String

        static func preview(id: Int) -> Props {
            .init(id: id,
                  text: "\(id): Label label label label label label label label label label label label label")
        }
    }
}

struct BallonView: View {
    @Environment(\.appUITheme) var theme
    let props: Props
    @State private var layoutWidth: CGFloat = 0

    var body: some View {
        makeBody
            .overlay(
                GeometryReader { geo in
                    Color.clear.onAppear { layoutWidth = geo.size.width }
                })
    }
}

struct BallonView_Previews: PreviewProvider {
    static var previews: some View {
        BallonView(props: .preview(id: 1))
    }
}

private extension BallonView {
    var makeBody: some View {
            HStack {
                textView
                Spacer(minLength: layoutWidth * maxSpacerProportionalWidth)

            }
            .background(theme.dialogueViewStyle.background)
            .padding(.leading, theme.baloonStyle.paddings.leftContentInset)
    }

    var text: some View {
        Text(props.text)
            .font(theme.baloonStyle.font)
            .foregroundColor(theme.baloonStyle.textColor)
            .padding(theme.baloonStyle.paddings.textPaddings)
            .lineLimit(nil)
//            .fixedSize(horizontal: false, vertical: false)
    }

    var textView: some View {
        ZStack {
            text
        }
        .background(theme.baloonStyle.background)
        .clipShape(RoundedRectangle(cornerRadius: theme.baloonStyle.borderRadius))
        .shadow(
            color: theme.baloonStyle.shadow.color
                .opacity(theme.baloonStyle.shadow.alpha),
            radius: theme.baloonStyle.shadow.blur,
            x: theme.baloonStyle.shadow.offset.width,
            y: theme.baloonStyle.shadow.offset.height)

        .padding(.leading, theme.baloonStyle.paddings.leftBodyInset)
    }

    var maxSpacerProportionalWidth: CGFloat {
        (1.0 - theme.baloonStyle.paddings.maxWidthProportion)
    }
}
