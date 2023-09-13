//
//  CurrencySymbolsDataProvider.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation
import Combine

protocol CurrencySymbolsDataProviderProtocol {
    func fetchSymbols() -> AnyPublisher<[CurrencySymbolModel], Error>
}

class CurrencySymbolsDataProvider: CurrencySymbolsDataProviderProtocol {
    
    private let currencyStore: CurrencyStore
    
    init(currencyStore: CurrencyStore = CurrencyStore()) {
        self.currencyStore = currencyStore
    }
    
    func fetchSymbols() -> AnyPublisher<[CurrencySymbolModel], Error> {
        return Future { promise in
            self.currencyStore.fetchSymbols { result, error in
                DispatchQueue.main.async {
                    if let error {
                        return promise(.failure(error))
                    }
                    
                    guard let symbols = result?.symbols else {
                        return // promise(.failure(error)) TODO: - Passar esse erro para a ViewModel
                    }
                    
                    let currenciesSymbol = symbols.map({ (key, value) -> CurrencySymbolModel in
                        return CurrencySymbolModel(symbol: key, fullName: value)
                    })
                    
                    return promise(.success(currenciesSymbol))
                }
            }
        }.eraseToAnyPublisher()
    }
    
}
