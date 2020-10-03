//
//  NavigationBarView.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import SwiftUI

extension NavigationBarView {
    struct Props {
        let title: String

        static var preview: Props {
            .init(title: "Title")
        }
    }
}

struct NavigationBarView: View {
    @Environment(\.appUITheme) var theme
    let props: Props

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .center) {
                Spacer()
                Text(props.title)
                    .font(theme.navBarStyle.titleFont)
                    .foregroundColor(theme.navBarStyle.titleColor)
                Spacer()
            }
            .frame(height: theme.navBarStyle.height)

            theme.navBarStyle.separatorColor
                .frame(height: 1)
        }
        .frame(height: theme.navBarStyle.height)
        .background(theme.navBarStyle.backgroundColor)
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(props: .preview)
    }
}
