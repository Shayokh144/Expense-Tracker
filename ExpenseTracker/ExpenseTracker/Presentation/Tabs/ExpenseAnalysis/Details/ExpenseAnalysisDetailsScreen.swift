//
//  ExpenseAnalysisDetailsScreen.swift
//  ExpenseTracker
//
//  Created by Taher's nimble macbook on 26/6/24.
//

import SwiftUI

struct ExpenseAnalysisDetailsScreen: View {
    
    @StateObject private var viewModel: ExpenseAnalysisDetailsViewModel
    @EnvironmentObject var navigator: AppCoordinatorViewModel
    
    private var maxBarNameLength: Double {
        UIScreen.main.bounds.width / 3.5
    }
    
    private var maxAvailableSpaceForBar: Double {
        let padding = 16.0 * 2.0
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth - padding - maxBarNameLength
    }
    
    private var backButton: some View {
        Button(
            action: {
                navigator.goBack()
            },
            label: {
                Image(systemName: "arrow.left.circle")
                    .foregroundStyle(Color(hexString: Constants.AppColors.tabSelectionColor))
            }
        )
    }
    
    var body: some View {
        VStack {
            barContentView(barChartInfo: viewModel.barChartUIModel)
        }
        .padding()
        .commonNavigationBar(
            title: "Expense Analysis Details",
            leftButton: { backButton },
            rightButton: { Color.clear }
        )
    }
    
    init(viewModel: ExpenseAnalysisDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func barContentView(barChartInfo: BarChartUIModel)-> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            ScrollView {
                ForEach(barChartInfo.chartData) { chartData in
                    HStack(spacing: 8.0) {
                        HStack {
                            Spacer()
                            Text(chartData.name)
                                .font(.system(size: 12.0))
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                        }
                        .frame(width: maxBarNameLength, height: 20.0)
                        barView(barData: chartData,  maxValue: barChartInfo.barItemMaxValue)
                        Spacer()
                    }
                }
            }
        }
        .padding(.bottom)
    }
    
    private func barView(barData: BarChartItemUIModel, maxValue: Double)-> some View {
        let mappedValue = barData.getMappedValue(
            maxValue: maxValue,
            maxAvailableSpace: maxAvailableSpaceForBar
        )
        return ZStack(alignment: .leading) {
            Color(hexString: Constants.AppColors.blueButtonColor)
                .frame(width: mappedValue,height: 24.0)
            barTextView(
                value: barData.actualValue.fractionOneDigitString,
                currency: barData.mappedCurrency
            )
        }
    }
    
    private func barTextView(value: String, currency: String)-> some View {
        HStack(alignment: .bottom, spacing: 2.0) {
            Text(value)
                .foregroundStyle(Color(hexString: Constants.AppColors.tabSelectionColor))
                .font(.system(size: 12.0, weight: .bold))
                .padding(.leading, 4.0)
            Text(currency)
                .foregroundStyle(Color(hexString: Constants.AppColors.tabSelectionColor))
                .font(.system(size: 10.0, weight: .bold))
            Spacer()
        }
    }
}
