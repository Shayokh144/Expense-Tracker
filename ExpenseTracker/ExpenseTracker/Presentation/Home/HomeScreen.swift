//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import SwiftUI

struct HomeScreen: View {

    private var loginGmailButton: some View {
        Button {

        } label: {
            Text("Login with Gmail")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: "#AD2533"),
                textColor: .white
            )
        )
    }

    private var searchLocationButton: some View {
        Button {

        } label: {
            Text("Search location in map")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: "#2529AD"),
                textColor: .white
            )
        )
    }

    private var seeCurrentLocationButton: some View {
        Button {

        } label: {
            Text("See current location in map")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: "#2529AD"),
                textColor: .white
            )
        )
    }

    var body: some View {
        VStack {
            loginGmailButton
            searchLocationButton
            seeCurrentLocationButton
        }
        .padding()
    }
}
