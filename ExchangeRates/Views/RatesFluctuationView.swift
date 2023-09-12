//
//  RatesFluctuationView.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import SwiftUI

struct RatesFluctuationView: View {
    @StateObject var viewModel = ViewModel()
    
    @State private var searchText = ""
    @State private var viewDidLoad = false
    @State private var isPresentedBaseCurrencyFilter = false
    @State private var isPresentedMultiCurrenciesFilter = false
    
    var searchResult: [RateFluctuationModel] {
        if searchText.isEmpty {
            return viewModel.ratesFluctuation
        } else {
            return viewModel.ratesFluctuation.filter {
                $0.symbol.contains(searchText.uppercased()) ||
                $0.change.formatter(decimalPlaces:  4).contains(searchText.uppercased()) ||
                $0.changePct.toPercentage().contains(searchText.uppercased()) ||
                $0.endRate.formatter(decimalPlaces: 2).contains(searchText.uppercased())
            }
        }
    }
    
    private var baseCurrencyPeriodFilterView: some View {
        HStack(alignment: .center, spacing: 16) {
            Button {
                isPresentedBaseCurrencyFilter.toggle()
            } label: {
                Text(viewModel.baseCurrency)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 1))
                    
            }
            .fullScreenCover(isPresented: $isPresentedBaseCurrencyFilter,
                             content: {
                BaseCurrencyFilterView(delegate: self)
            })
            .background(Color(UIColor.lightGray))
            .cornerRadius(8)
            
            Button {
                viewModel.doFetchTimeSeries(timeRange: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .today ? true : false)
            }
            
            Button {
                viewModel.doFetchTimeSeries(timeRange: .thisWeek)
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisWeek ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisWeek ? true : false)

            }
            
            Button {
                viewModel.doFetchTimeSeries(timeRange: .thisMonth)
            } label: {
                Text("1 mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisMonth ? true : false)
            }
            
            Button {
                viewModel.doFetchTimeSeries(timeRange: .thisSemester)
            } label: {
                Text("6 meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisSemester ? true : false)
            }
            
            Button {
                viewModel.doFetchTimeSeries(timeRange: .thisYear)
            } label: {
                Text("1 ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisYear ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisYear ? true : false)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var ratesFluctuationsListView: some View {
        List(searchResult) { fluctuation in
            NavigationLink(destination: RateFluctuationDetailView(baseCurrency: viewModel.baseCurrency,
                                                                   rateFluctuation: fluctuation)) {
                VStack {
                    HStack(alignment: .center, spacing: 8) {
                        Text("\(fluctuation.symbol) / \(viewModel.baseCurrency)")
                            .font(.system(size: 14, weight: .medium))
                        Text("\(fluctuation.endRate.formatter(decimalPlaces: 2))")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("\(fluctuation.change.formatter(decimalPlaces: 4, with: true))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(fluctuation.change.color)
                        Text("\(fluctuation.changePct.toPercentage(with: true))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(fluctuation.changePct.color)
                    }
                    
                    Divider()
                        .padding(.leading, -20)
                        .padding(.trailing, -40)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.white)
        }
        .listStyle(.plain)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                baseCurrencyPeriodFilterView
                ratesFluctuationsListView
            }
            .searchable(text: $searchText)
            .navigationTitle("Conversão de Moedas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isPresentedMultiCurrenciesFilter.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .fullScreenCover(isPresented: $isPresentedMultiCurrenciesFilter, content: {
                    MultiCurrenciesFilterView(delegate: self)
                })
            }
        }
        .onAppear {
            if !viewDidLoad {
                viewModel.doFetchTimeSeries(timeRange: .today)
                viewDidLoad = true
            }
        }
    }
}

extension RatesFluctuationView: MultiCurrenciesFilterViewDelegate {
    func didSelection(_ currencies: [String]) {
        viewModel.currencies = currencies
        viewModel.doFetchTimeSeries(timeRange: .today)
    }
}

extension RatesFluctuationView: BaseCurrencyFilterViewDelegate {
    func didSelected(_ baseCurrency: String) {
        viewModel.baseCurrency = baseCurrency
        viewModel.doFetchTimeSeries(timeRange: .today)
    }
}

struct RatesFluctuationView_Previews: PreviewProvider {
    static var previews: some View {
        RatesFluctuationView()
    }
}
