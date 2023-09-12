//
//  RatesHistoricalDataProvider.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation

protocol RatesHistoricalDataProviderDelegate: DataProviderManagerDelegate {
    func success(model: [RateHistoricalModel])
}

class RatesHistoricalDataProvider: DataProviderManager<RatesHistoricalDataProviderDelegate,
    [RateHistoricalModel]>
{
    private let ratesStore = RatesStore()
    
    func fetchTimeseries(by base: String,
                         from symbols: String,
                         startDate: String,
                         endDate: String) {
        Task.init {
            do {
                let object = try await ratesStore.fetchTimeseries(by: base,
                                                                 from: symbols,
                                                                 startDate: startDate,
                                                                 endDate: endDate)
                delegate?.success(model: object.flatMap({ (period, rates) -> [RateHistoricalModel] in
                    return rates.map { RateHistoricalModel(symbol: $0, period: period.toDate(), endRate: $1)  }
                }))
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
