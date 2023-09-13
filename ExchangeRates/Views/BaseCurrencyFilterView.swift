//
//  BaseCurrencyFilterView.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import SwiftUI

protocol BaseCurrencyFilterViewDelegate {
    func didSelected(_ baseCurrency: String)
}

struct BaseCurrencyFilterView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = ViewModel()

    @State private var selection: String?
    @State private var searchText = ""

    var delegate: BaseCurrencyFilterViewDelegate?

    private var listCurrenciesView: some View {
        List(viewModel.searchResults, id: \.symbol, selection: $selection) { item in
            HStack {
                Text(item.symbol)
                    .font(.system(size: 14, weight: .bold))
                Text("-")
                    .font(.system(size: 14, weight: .semibold))
                Text(item.fullName)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .searchable(text: $searchText, prompt: "Buscar moeda base")
        .onChange(of: searchText) { searchText in
            if searchText.isEmpty {
                viewModel.searchResults = viewModel.currencySymbols
            } else {
                viewModel.searchResults = viewModel.currencySymbols.filter {
                    $0.symbol.contains(searchText.uppercased()) ||
                    $0.fullName.uppercased().contains(searchText.uppercased())
                }
            }
        }
        .navigationTitle("Filtrar Moedas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                if let selection {
                    delegate?.didSelected(selection)
                }
                dismiss()
            } label: {
                Text("OK")
                    .fontWeight(.bold)
            }
        }
    }
    
    private var errorView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .frame(width: 60, height: 44)
                .padding(.bottom, 4)
            
            Text("Ocorreu um erro na busca dos simbolos das moedas")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.doFetchCurrencySymbols()
            } label: {
                Text("Tentar novamente")
            }
            .padding(.top, 4)
            
            Spacer()
        }
    }

    var body: some View {
        NavigationView {
            if case .loading = viewModel.currentState {
                ProgressView()
                    .scaleEffect(2.2, anchor: .center)
            } else if case .success = viewModel.currentState {
                listCurrenciesView
            } else if case .failure = viewModel.currentState {
                errorView
            }
            
        }
        .onAppear {
            viewModel.doFetchCurrencySymbols()
        }
    }
}

struct BaseCurrencyFilterView_Previews: PreviewProvider {
    static var previews: some View {
        BaseCurrencyFilterView()
    }
}
