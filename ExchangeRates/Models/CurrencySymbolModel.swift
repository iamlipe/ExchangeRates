//
//  CurrencySymbolModel.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import Foundation

struct CurrencySymbolModel: Identifiable, Equatable {
    let id = UUID()
    var symbol: String
    var fullName: String
}
