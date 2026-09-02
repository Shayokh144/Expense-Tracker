//
//  CommonNavigationBar.swift
//  ExpenseTracker
//
//  Created by Taher's nimble macbook on 9/4/24.
//

import SwiftUI

struct CommonNavigationBarModifier<LeftButton: View, RightButton: View>: ViewModifier {

    private let leftButton: LeftButton
    private let rightButton: RightButton
    private let title: String
    private let showsRightButton: Bool

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leftButton
                }
                if showsRightButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        rightButton
                    }
                }
            }
    }

    init(
        title: String,
        showsRightButton: Bool = true,
        @ViewBuilder leftButton: () -> LeftButton,
        @ViewBuilder rightButton: () -> RightButton
    ) where LeftButton: View, RightButton: View {
        self.title = title
        self.showsRightButton = showsRightButton
        self.leftButton = leftButton()
        self.rightButton = rightButton()
    }
}
