//
//  ExpenseAnalysisScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct ExpenseAnalysisScreen: View {
    
    @StateObject private var viewModel: ExpenseAnalysisViewModel
    
    private var maxBarNameLength: Double {
        UIScreen.main.bounds.width / 3.5
    }
    
    private var maxAvailableSpaceForBar: Double {
        let padding = 16.0 * 3.0
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth - padding - maxBarNameLength
    }
        
    private var dayInputView: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                TextField("Last N days", text: $viewModel.numberOfDay)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button(
                    action: viewModel.findAnalytics,
                    label: {
                        Text("Show Analysis")
                            .padding(.horizontal, 4.0)
                    }
                )
                .buttonStyle(
                    TextButtonStyle(
                        backgroundColor: .green,
                        textColor: .black
                    )
                )
            }
            if !viewModel.error.isEmpty {
                Text(viewModel.error)
                    .foregroundStyle(Color.red)
                    .font(.system(size: 12.0))
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: .zero) {
            Spacer()
            ProgressView()
                .scaleEffect(2)
            Spacer()
        }
    }
    
    private var chartView: some View {
        ForEach(viewModel.barChartUIModel) { barChartInfo in
            VStack(alignment: .center) {
                Text(barChartInfo.name)
                    .padding(.top)
                graphSummaryView(barChartInfo: barChartInfo)
                dateRowView(startDate: barChartInfo.startDate, endDate: barChartInfo.endDate)
                Divider()
                    .padding(.bottom, 4.0)
                barContentView(barChartInfo: barChartInfo)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            Text("Expense Analysis")
                .font(.system(.title2))
                .padding([.bottom, .horizontal])
            switch viewModel.state {
                case .loading:
                    loadingView
                        .padding(.horizontal)
                case .loaded:
                    dayInputView
                        .padding(.horizontal)
                    TabView {
                        chartView
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(18.0)
                            .padding([.horizontal, .top])
                            .padding(.bottom, 48.0)
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
    
    init(viewModel: ExpenseAnalysisViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func dateRowView(startDate: String, endDate: String)-> some View {
        HStack(spacing: .zero) {
            Text("\(endDate)")
                .font(.system(size: 14.0, weight: .bold))
            Spacer()
            Text("To")
                .font(.system(size: 12.0, weight: .regular))
            Spacer()
            Text("\(startDate)")
                .font(.system(size: 14.0, weight: .bold))
        }
        .padding(.horizontal)
        .padding(.bottom, 8.0)
    }
    
    private func graphSummaryView(barChartInfo: BarChartUIModel)-> some View {
        HStack(spacing: 4.0) {
            Text("Total:")
                .font(.system(size: 14.0, weight: .bold))
            Text("\(barChartInfo.total.fractionOneDigitString)")
                .font(.system(size: 20.0, weight: .bold))
            Spacer()
            CurrencyPickerView(
                currencyList: Constants.AppData.currencyList,
                selectedCurrency: .init(
                    get: {
                        barChartInfo.currency
                    },
                    set: { newValue in
                        viewModel.onChangeCurrency(newCurrency: newValue, dataId: barChartInfo.id)
                    }
                )
            )
            .accentColor(Color(hexString: Constants.AppColors.tabSelectionColor))
        }
        .padding(.horizontal)
        .padding(.vertical, 8.0)
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
