//
//  RestesFluctuationObject.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 06/09/23.
//

import Foundation

typealias RatesFluctuationObject = [String: FluctuationObject]

struct FluctuationObject: Codable {
    let startRate: Double
    let endRate: Double
    let change: Double
    let changePct: Double
    
    enum CodingKeys: String, CodingKey {
        case startRate = "start_rate"
        case endRate = "end_rate"
        case change = "change"
        case changePct = "change_pct"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.startRate = (try? container.decode(Double.self, forKey: .startRate)) ?? 0.0
        self.endRate = (try? container.decode(Double.self, forKey: .endRate)) ?? 0.0
        self.change = try container.decode(Double.self, forKey: .change)
        self.changePct = try container.decode(Double.self, forKey: .changePct)
    }
}
