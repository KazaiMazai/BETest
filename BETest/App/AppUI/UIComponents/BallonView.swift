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

        static func empty(id: Int) -> Props {
            .init(id: id, text: "Label Label Label Label Label Label Label Label Label Label Label Label Label Label LabelLabelLabel Label Label Label Label Label Label Label Label Label LabelLabelLabelLabelLabel Label LabelLabel LabelLabel LabelLabel Label")
        }
    }
}

struct BallonView: View {
    @Environment(\.appUITheme) var theme
    let props: Props

    var body: some View {
        makeBody
    }
}

struct BallonView_Previews: PreviewProvider {
    static var previews: some View {
        BallonView(props: .empty(id: 1))
    }
}

private extension BallonView {
    var makeBody: some View {
        GeometryReader { geo in
            HStack {
                textView
                Spacer(minLength: geo.size.width * 0.25)

            }
            .background(theme.dialogueViewStyle.background)
            .padding(.leading, theme.baloonStyle.paddings.leftContentInset)
        }
    }

    var text: some View {
        Text(props.text)
            .font(theme.baloonStyle.font)
            .foregroundColor(theme.baloonStyle.textColor)
            .padding(theme.baloonStyle.paddings.textPaddings)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: false)
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
}
