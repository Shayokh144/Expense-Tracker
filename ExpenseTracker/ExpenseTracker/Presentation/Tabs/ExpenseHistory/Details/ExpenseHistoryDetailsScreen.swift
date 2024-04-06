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
    
    var body: some View {
        VStack {
            Text("EXPENSE DETAILS")
            Button(
                action: onTapBack,
                label: {
                    Text("...BACK...")
                }
            )
            Spacer()
        }
        .background(Color.blue)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // BACK BUTTON
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navigator.goBack()
                }) {
                    Label("Back", systemImage: "arrow.left.circle")
                }
            }
        }
    }
        
    
    init(onTapBack: @escaping () -> Void) {
        self.onTapBack = onTapBack
    }
}
