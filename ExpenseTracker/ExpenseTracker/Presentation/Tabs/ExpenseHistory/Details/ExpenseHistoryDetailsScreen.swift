//
//  ExpenseHistoryDetailsScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 7/2/24.
//

import SwiftUI

struct ExpenseHistoryDetailsScreen: View {
    
    @EnvironmentObject var navigator: AppCoordinatorViewModel
    private let onTapBack: () -> Void
    
    private var backButton: some View {
        Button(
            action: {
                navigator.goBack()
            },
            label: {
                Label("Back", systemImage: "arrow.left.circle")
            }
        )
    }
    
    var body: some View {
        VStack {
            Text("Show details")
            Spacer()
        }
        .commonNavigationBar(
            title: "Expense Details",
            leftButton: { backButton },
            rightButton: { Color.clear }
        )
    }
        
    
    init(onTapBack: @escaping () -> Void) {
        self.onTapBack = onTapBack
    }
}
