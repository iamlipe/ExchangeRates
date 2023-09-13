//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 06/09/23.
//

import Foundation

enum RatesRouter {
    case fluctuation(startDate: String, endDate: String, base: String, symbols: [String])
    case timeseries(startDate: String, endDate: String, base: String, symbols: String)
    
    var path: String {
        switch self {
        case.fluctuation:
            return RatesApi.fluctuation
        case .timeseries:
            return RatesApi.timeseries
        }
    }
    
    func asUrlRequest() -> URLRequest? {
        guard var url = URL(string: RatesApi.baseUrl) else {
            return nil
        }
                
        switch self {
        case .fluctuation(let startDate, let endDate, let base, let symbols):
            url.append(queryItems: [
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate),
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")),
            ])
        case .timeseries(let startDate, let endDate, let base, let symbols):
            url.append(queryItems: [
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate),
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbols),
            ])
        }
            
        var request = URLRequest(url: url.appendingPathComponent(path), timeoutInterval: Double.infinity)
        
        request.httpMethod = HttpMethod.get.rawValue
        request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apikey")
        
        return request
    }
    
}
