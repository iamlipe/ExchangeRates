//
//  CurrencySelectionFilterView.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import SwiftUI


protocol MultiCurrenciesFilterViewDelegate {
    func didSelection (_ currencies: [String])
}

struct MultiCurrenciesFilterView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = ViewModel()
    
    @State private var searchText = ""
    @State private var selections: [String] = []
    
    var delegate: MultiCurrenciesFilterViewDelegate?
    
    var searchResults: [CurrencySymbolModel] {
        if searchText.isEmpty {
            return viewModel.currencySymbols
        } else {
            return viewModel.currencySymbols.filter {
                $0.symbol.contains(searchText.uppercased()) ||
                $0.fullName.uppercased().contains(searchText.uppercased())
            }
        }
    }
    
    private var listCurrenciesView: some View {
        List(searchResults, id: \.symbol) { item in
            Button {
                if selections.contains(item.symbol) {
                    selections.removeAll {
                        $0 == item.symbol
                    }
                } else {
                    selections.append(item.symbol)
                }
                
            } label: {
                HStack {
                    HStack {
                        Text(item.symbol)
                            .font(.system(size: 14, weight: .bold))
                        Text("-")
                            .font(.system(size: 14, weight: .semibold))
                        Text(item.fullName)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .opacity(selections.contains(item.symbol) ? 1.0 : 0.0)
                }
                
            }
            .foregroundColor(.primary)
        }
        .searchable(text: $searchText)
        .navigationTitle("Filtrar Moedas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                if !selections.isEmpty {
                    delegate?.didSelection(selections)
                }
                
                dismiss()
            } label: {
                Text(selections.isEmpty ? "Cancelar" : "OK")
                    .fontWeight(.bold)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            listCurrenciesView
        }
        .onAppear {
            viewModel.doFetchCurrencySymbols()
        }
    }
    
    
}

struct CurrencySelectionFilterView_Previews: PreviewProvider {
    static var previews: some View {
        MultiCurrenciesFilterView()
    }
}
