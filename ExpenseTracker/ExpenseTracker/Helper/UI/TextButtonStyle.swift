//
//  TextButtonStyle.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import SwiftUI

struct TextButtonStyle: ButtonStyle {

    private let backgroundColor: Color
    private let textColor: Color
    private let cornerRadius: CGFloat
    private let font: Font
    private let textPadding: EdgeInsets

    init(
        backgroundColor: Color = .blue,
        textColor: Color = .white,
        cornerRadius: CGFloat = 10.0,
        font: Font = .system(size: 16.0, weight: .bold),
        textPadding: EdgeInsets = EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.font = font
        self.textPadding = textPadding
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(textColor)
            .padding(textPadding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
