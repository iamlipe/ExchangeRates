//
//  RatesFluctuationDataProvider.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation

protocol RatesFluctuationDataProviderDelegate: DataProviderManagerDelegate {
    func success(model: [RateFluctuationModel])
}

class RatesFluctuationDataProvider: DataProviderManager<RatesFluctuationDataProviderDelegate, [RateFluctuationModel]>
{
    private let ratesStore = RatesStore()

    func fetchFlucutuation(by base: String,
                           from symbols: [String],
                           startDate: String,
                           endDate: String) {
        Task.init {
            do {
                let object = try await ratesStore.fetchFluctuation(by: base,
                                                                  from: symbols,
                                                                  startDate: startDate,
                                                                  endDate: endDate)
                                
                delegate?.success(model: object.map ({ (symbol, fluctuation) -> RateFluctuationModel in
                    return RateFluctuationModel(symbol: symbol,
                                                change: fluctuation.change,
                                                changePct: fluctuation.changePct,
                                                endRate: fluctuation.endRate)
                }))
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
