//
//  CurrencySymbolsObject.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 07/09/23.
//

import Foundation

struct CurrencySymbolObject: Codable {
    var base: String?
    var success: Bool = false
    var symbols: SymbolObject?
}

typealias SymbolObject = [String: String]
