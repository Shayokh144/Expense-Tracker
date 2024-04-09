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

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leftButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    rightButton
                }
            }
    }

    init(
        title: String,
        @ViewBuilder leftButton: () -> LeftButton,
        @ViewBuilder rightButton: () -> RightButton
    ) where LeftButton: View, RightButton: View {
        self.title = title
        self.leftButton =  leftButton()
        self.rightButton =  rightButton()
    }
}
