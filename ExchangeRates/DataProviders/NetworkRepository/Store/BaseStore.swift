//
//  BaseStore.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 06/09/23.
//

import Foundation

class BaseStore {
    let error = NSError(
        domain: "",
        code: 901,
        userInfo: [NSLocalizedDescriptionKey: "Error get Information"])
    
    struct RateResult<Rates: Codable>: Codable {
        var base: String?
        var success: Bool = false
        var rates: Rates?
        
        init(data: Data?, response: URLResponse?) throws {
            guard let data = data else {
                throw NSError(
                    domain: "",
                    code: 901,
                    userInfo: [NSLocalizedDescriptionKey: "Error get Information"])
            }
                    
            self = try JSONDecoder().decode(RateResult.self, from: data)
        }
    }

    struct SymbolResult: Codable {
        var base: String?
        var success: Bool = false
        var symbols: CurrencySymbolsObject?
        
        init(data: Data?, response: URLResponse?) throws {
            guard let data = data else {
                throw NSError(
                    domain: "",
                    code: 901,
                    userInfo: [NSLocalizedDescriptionKey: "Error get Information"])
            }
            
            self = try JSONDecoder().decode(SymbolResult.self, from: data)
        }
    }
}


