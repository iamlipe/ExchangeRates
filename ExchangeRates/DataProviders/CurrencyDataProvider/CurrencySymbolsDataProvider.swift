//
//  CurrencySymbolsDataProvider.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation

protocol CurrencySymbolsDataProviderDelegate: DataProviderManagerDelegate {
    func success(model: [CurrencySymbolModel])
}

class CurrencySymbolsDataProvider: DataProviderManager<CurrencySymbolsDataProviderDelegate, [CurrencySymbolModel]> {
    private let symbolsResult = CurrencyStore()
    
    func fetchSymbols() {
        Task.init {
            do {
                let object = try await symbolsResult.fetchSymbols()
                
                delegate?.success(model: object.map { (symbol, fullName) -> CurrencySymbolModel in
                    return CurrencySymbolModel(symbol: symbol, fullName: fullName)
                })
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
 
}
