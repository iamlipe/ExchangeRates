//
//  RatesStore.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation

protocol RatesStoreProtocol: GenericStoreProtocol {
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesFluctuationObject>?>)
    func fetchTimeseries(by base: String, from symbols: String, startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesHistoricalObject>?>)
}

class RatesStore: GenericStoreRequest, RatesStoreProtocol {
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String, completion:  @escaping completion<RateObject<RatesFluctuationObject>?>) {
        guard let urlRequest = RatesRouter.fluctuation(startDate: startDate, endDate: endDate, base: base, symbols: symbols).asUrlRequest() else {
            return completion(nil, error)
        }
        
        request(urlRequest: urlRequest, completion: completion)
    }
    
    func fetchTimeseries(by base: String, from symbols: String, startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesHistoricalObject>?>) {
        guard let urlRequest = RatesRouter.timeseries(startDate: startDate, endDate: endDate, base: base, symbols: symbols).asUrlRequest() else {
            return completion(nil, error)
        }
        
        request(urlRequest: urlRequest, completion: completion)
    }
}
