//
//  BallonView.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

extension BallonView {
    struct Props<ID: Hashable>: Identifiable {
        let id: ID
        let text: String

        static func preview(id: Int) -> Props<Int> {
            Props<Int>(
                id: id,
                text: "\(id): Label label label label label label label label label label label label label")
        }
    }
}

struct BallonView<ID: Hashable>: View {
    @Environment(\.appUITheme) var theme
    let props: Props<ID>
    let maxLayoutWidth: CGFloat

    var body: some View {
        makeBody
    }
}

struct BallonView_Previews: PreviewProvider {
    static var previews: some View {
        BallonView(props: .preview(id: 1), maxLayoutWidth: 414)
    }
}

private extension BallonView {
    var makeBody: some View {
        HStack {
            textView
            Spacer(minLength: maxLayoutWidth * minSpacerProportionalWidth)
        }
        .animation(nil)
        .background(theme.dialogueViewStyle.backgroundColor)
        .padding(.leading, theme.baloonStyle.paddings.leftContentInset)
    }

    var text: some View {
        Text(props.text)
            .font(theme.baloonStyle.font)
            .foregroundColor(theme.baloonStyle.textColor)
            .padding(.vertical, theme.baloonStyle.paddings.textPaddings)
            .padding(.trailing, theme.baloonStyle.paddings.textPaddings)
            .padding(.leading, theme.baloonStyle.paddings.textPaddings + theme.baloonStyle.paddings.leftBodyInset)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: false)
    }
    
    var textView: some View {
        Group {
            text
        }
        .background(theme.baloonStyle.backgroundColor)
        .clipShape(
            Bubble(radius: theme.baloonStyle.borderRadius,
                   leftPadding: theme.baloonStyle.paddings.leftBodyInset,
                   triangularHeight: theme.baloonStyle.paddings.triangularHeight))
        .shadow(
            color: theme.baloonStyle.shadow.color
                .opacity(theme.baloonStyle.shadow.alpha),
            radius: theme.baloonStyle.shadow.blur,
            x: theme.baloonStyle.shadow.offset.width,
            y: theme.baloonStyle.shadow.offset.height)
    }

    var minSpacerProportionalWidth: CGFloat {
        (1.0 - theme.baloonStyle.paddings.maxWidthProportion)
    }
}

private struct Bubble: Shape {
    let radius: CGFloat
    let leftPadding: CGFloat
    let triangularHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))

        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - radius), control: CGPoint(x: rect.maxX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + radius))

        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.minX + leftPadding + radius, y: rect.minY))

        path.addQuadCurve(
            to: CGPoint(x: rect.minX + leftPadding, y: rect.minY + radius),
            control: CGPoint(x: rect.minX + leftPadding, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.minX + leftPadding,
                                 y: rect.maxY - triangularHeight - radius ))

        path.addQuadCurve(
            to: CGPoint(x: rect.minX + leftPadding, y: rect.maxY - triangularHeight + radius / 2),
            control: CGPoint(x: rect.minX + leftPadding, y: rect.maxY - triangularHeight))

        path.addLine(to: CGPoint(x: rect.minX + radius / 1.5,
                                 y: rect.maxY - radius ))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

