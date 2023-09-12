//
//  RateHistoricalModel.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import Foundation

struct RateHistoricalModel: Identifiable, Equatable {
    let id = UUID()
    var symbol: String
    var period: Date
    var endRate: Double
}
