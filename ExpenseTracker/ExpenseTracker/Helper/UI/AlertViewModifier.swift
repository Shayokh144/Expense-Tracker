//
//  AlertViewModifier.swift
//  ExpenseTracker
//
//  Created by Taher on 22/1/24.
//

import SwiftUI

struct AlertViewModifier: ViewModifier {

    @Binding private var isPresenting: Bool
    private let title: String
    private let description: String
    private let isError: Bool
    private let didTap: (() -> Void)

    init(
        isPresenting: Binding<Bool>,
        title: String,
        description: String,
        isError: Bool,
        didTap: @escaping () -> Void
    ) {
        _isPresenting = isPresenting
        self.title = title
        self.description = description
        self.isError = isError
        self.didTap = didTap
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresenting {
                AlertView(
                    title: title,
                    message: description,
                    isError: isError,
                    didTap: {
                        didTap()
                    }
                )
            }
        }
    }
}

