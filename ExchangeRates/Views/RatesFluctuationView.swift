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
                viewModel.doFetchRatesFluctuation(timeRange: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .today ? true : false)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisWeek)
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisWeek ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisWeek ? true : false)

            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisMonth)
            } label: {
                Text("1 mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisMonth ? true : false)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisSemester)
            } label: {
                Text("6 meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .accentColor : .gray)
                    .underline(viewModel.timeRange == .thisSemester ? true : false)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisYear)
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
        List(viewModel.searchResults) { fluctuation in
            NavigationLink(destination: RateFluctuationDetailView(baseCurrency: viewModel.baseCurrency,
                                                                  fromCurrency: fluctuation.symbol)) {
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
    
    private var errorView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .frame(width: 60, height: 44)
                .padding(.bottom, 4)
            
            Text("Ocorreu um erro na busca das flutuações das taxas!")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .today)
            } label: {
                Text("Tentar novamente")
            }
            .padding(.top, 4)
            
            Spacer()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if case .loading = viewModel.currentState {
                    ProgressView()
                        .scaleEffect(2.2, anchor: .center)
                } else if case .success = viewModel.currentState {
                    baseCurrencyPeriodFilterView
                    ratesFluctuationsListView
                } else if case .failure = viewModel.currentState {
                    errorView
                }
            }
            .searchable(text: $searchText, prompt: "Procurar moeda")
            .onChange(of: searchText) { searchText in
                if searchText.isEmpty {
                    viewModel.searchResults = viewModel.ratesFluctuation
                } else {
                    viewModel.searchResults = viewModel.ratesFluctuation.filter {
                        $0.symbol.contains(searchText.uppercased()) ||
                        $0.change.formatter(decimalPlaces: 6).contains(searchText) ||
                        $0.changePct.formatter(decimalPlaces: 6).contains(searchText) ||
                        $0.endRate.formatter(decimalPlaces: 6).contains(searchText)
                    }
                }
            }
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
                viewModel.doFetchRatesFluctuation(timeRange: .today)
                viewDidLoad = true
            }
        }
    }
}

extension RatesFluctuationView: MultiCurrenciesFilterViewDelegate {
    func didSelection(_ currencies: [String]) {
        viewModel.currencies = currencies
        viewModel.doFetchRatesFluctuation(timeRange: .today)
    }
}

extension RatesFluctuationView: BaseCurrencyFilterViewDelegate {
    func didSelected(_ baseCurrency: String) {
        viewModel.baseCurrency = baseCurrency
        viewModel.doFetchRatesFluctuation(timeRange: .today)
    }
}

struct RatesFluctuationView_Previews: PreviewProvider {
    static var previews: some View {
        RatesFluctuationView()
    }
}
