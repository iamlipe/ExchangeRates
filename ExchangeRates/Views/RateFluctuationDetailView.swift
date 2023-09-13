//
//  RateFluctuationDetailView.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import SwiftUI
import Charts

struct RateFluctuationDetailView: View {
    @StateObject var viewModel = ViewModel()
    
    @State var baseCurrency: String
    @State var fromCurrency: String
    @State private var isPresentedBaseCurrencyFilter = false
    
    private var valuesView: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(viewModel.endRate.formatter(decimalPlaces: 4))
                .font(.system(size: 28, weight: .bold))
            Text(viewModel.changePct.toPercentage(with: true))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(viewModel.change.color)
                .background(viewModel.changePct.color.opacity(0.2))
            Text(viewModel.changeDescription)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(viewModel.change.color)
            Spacer()
        }
        .padding(8)
    }
    
    private var lineChartView: some View {
        Chart(viewModel.ratesHistorical) { item in
            LineMark(x: .value("Period", item.period),
                     y: .value("Rates", item.endRate))
            .interpolationMethod(.cardinal)
            
            if !viewModel.hasRates {
                RuleMark(y: .value("Conversão Zero", 0))
                    .annotation(position: .overlay, alignment: .center) {
                        Text("Sem valores nesse periodo")
                            .font(.footnote)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                    }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned,
                      values: .stride(by: viewModel.xAxisStride,
                                      count: viewModel.xAxisStrideCount)) { date in
                AxisGridLine()
                AxisValueLabel(viewModel.xAxisLabelFormatStyle(for: date.as(Date.self) ?? Date() ))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { rate in
                AxisGridLine()
                AxisValueLabel(rate.as(Double.self)?.formatter(decimalPlaces: 3) ?? 0.0.formatter(decimalPlaces: 3))
            }
        }
        .chartYScale(domain: viewModel.yAxisMin...viewModel.yAxisMax)
        .frame(height: 260)
        .padding(.init(top: 8, leading: 16, bottom: 40, trailing: 24))
    }
    
    private var periodFilterView: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.doFetchData(from: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .today)
            }
            
            Button {
                viewModel.doFetchData(from: .thisWeek)
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisWeek ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisWeek)
            }
            
            Button {
                viewModel.doFetchData(from: .thisMonth)
            } label: {
                Text("1 mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisMonth)
            }
            
            Button {
                viewModel.doFetchData(from: .thisSemester)
            } label: {
                Text("6 meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisSemester)
            }
            
            Button {
                viewModel.doFetchData(from: .thisYear)
            } label: {
                Text("1 ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisYear ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisYear)
            }
        }
        .padding(.vertical, 16)
    }
    
    private var comparationView: some View {
        VStack {
            Button {
                isPresentedBaseCurrencyFilter.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                Text("Comparar com")
                    .font(.system(size: 16))
            }.fullScreenCover(isPresented: $isPresentedBaseCurrencyFilter, content: {
                BaseCurrencyFilterView(delegate: self)
            })
            .opacity(viewModel.ratesFluctuation.count == 0 ? 0 : 1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible())], alignment: .center) {
                    ForEach(viewModel.ratesFluctuation) { fluctuation in
                        Button {
                            viewModel.doComparation(with: fluctuation)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(fluctuation.symbol) / \(baseCurrency)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text(fluctuation.endRate.formatter(decimalPlaces: 4))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
            
                                HStack {
                                    Text(fluctuation.symbol)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(fluctuation.changePct.toPercentage())
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(fluctuation.changePct.color)
                                }
                            }
                        }
                        .padding(8)
                        .frame(width: 160, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            valuesView
            periodFilterView
            lineChartView
            comparationView
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startStateView(baseCurrency: baseCurrency, fromCurrency: fromCurrency, timeRange: .today)
        }
    }
}

extension RateFluctuationDetailView: BaseCurrencyFilterViewDelegate {
    func didSelected(_ baseCurrency: String) {
        viewModel.doFilter(by: baseCurrency)
    }
}

struct RateFluctuationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RateFluctuationDetailView(baseCurrency: "BRL",
                                  fromCurrency: "USD")
    }
}
