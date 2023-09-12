//
//  RatesStore.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation

protocol RatesStoreProtocol {
    func fetchFluctuation(by base: String,
                          from symbols: [String],
                          startDate: String,
                          endDate: String) async throws -> RatesFluctuationObject
    func fetchTimeseries(by base: String,
                         from symbols: String,
                         startDate: String,
                         endDate: String) async throws -> RatesHistoricalObject
}

class RatesStore: BaseStore, RatesStoreProtocol {
    func fetchFluctuation(by base: String,
                          from symbols: [String],
                          startDate: String,
                          endDate: String) async throws -> RatesFluctuationObject {
        
        guard let urlRequest = try RatesRouter.fluctuation(startDate: startDate,
                                                           endDate: endDate,
                                                           base: base,
                                                           symbols: symbols).asUrlRequest() else {
            throw error
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
                
        guard let rates = try RateResult<RatesFluctuationObject>(data: data,
                                                                 response: response).rates else {
            throw error
        }
                        
        return rates
    }
    
    func fetchTimeseries(by base: String,
                         from symbols: String,
                         startDate: String,
                         endDate: String) async throws -> RatesHistoricalObject {
        guard let urlRequest = try RatesRouter.timeseries(startDate: startDate,
                                                          endDate: endDate,
                                                          base: base,
                                                          symbols: symbols).asUrlRequest()
        else { throw error }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let timeseries = try RateResult<RatesHistoricalObject>(data: data,
                                                                     response: response).rates
        else { throw error }
        
        return timeseries
    }
}
