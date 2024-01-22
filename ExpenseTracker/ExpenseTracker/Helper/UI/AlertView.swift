//
//  AlertView.swift
//  ExpenseTracker
//
//  Created by Taher on 22/1/24.
//

import SwiftUI

struct AlertView: View {

    let title: String
    let message : String
    let isError: Bool
    let didTap: (() -> Void)
    private let baseColor: Color

    var body: some View {
        VStack (spacing: .zero) {
            Text(title)
                .font(.system(size: 16.0, weight: .bold))
                .foregroundColor(baseColor)
                .padding([.horizontal, .top])
                .frame(maxWidth: 300)
                .background(.white)
                .clipShape(
                    RoundedCornerShape(
                        corners: [.topLeft, .topRight], radius: 10.0
                    )
                )
            Text(message)
                .font(.system(size: 14.0, weight: .regular))
                .foregroundColor(.black)
                .padding(16.0)
                .padding(.bottom, 8.0)
                .frame(maxWidth: 300)
                .background(.white)

            Button {
                didTap()
            } label: {
                Text("Ok")
                    .font(.system(size: 16.0, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 300, maxHeight: 30)
            }
            .frame(maxWidth: 300, maxHeight: 30)
            .background(LinearGradient(
                colors: [.black, baseColor, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .clipShape(
                RoundedCornerShape(
                    corners: [.bottomLeft, .bottomRight], radius: 10.0
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.4))
    }

    init(
        title: String,
        message: String,
        isError: Bool,
        didTap: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.isError = isError
        self.didTap = didTap
        baseColor = isError ? .red : .green
    }
}

struct RoundedCornerShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

