//
//  View+Extension.swift
//  ExpenseTracker
//
//  Created by Taher on 12/1/24.
//

import Combine
import SwiftUI

extension View {

    func alertView(
        isPresenting: Binding<Bool>,
        title: String,
        description: String,
        isError: Bool,
        didTap: @escaping () -> Void
    ) -> some View {
        modifier(
            AlertViewModifier(
                isPresenting: isPresenting,
                title: title,
                description: description,
                isError: isError,
                didTap: didTap
            )
        )
    }
}
