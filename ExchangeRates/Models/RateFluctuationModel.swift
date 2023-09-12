//
//  RateFluctuationModel.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import Foundation

struct RateFluctuationModel: Identifiable, Equatable {
    let id = UUID()
    var symbol: String
    var change: Double
    var changePct: Double
    var endRate: Double
}
