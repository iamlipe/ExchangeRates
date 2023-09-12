//
//  RatesApi.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 06/09/23.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
}

enum RatesApi {
    static let baseUrl = "https://api.apilayer.com/exchangerates_data"
    static let apiKey = "wKXvM0hchYzrsVYOA2rPfQXe7NlvpPaz"
    static let fluctuation = "/fluctuation"
    static let symbols = "/symbols"
    static let timeseries = "/timeseries"
}
