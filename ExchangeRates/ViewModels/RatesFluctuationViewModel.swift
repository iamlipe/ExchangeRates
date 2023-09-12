//
//  RatesFluctuationViewModel.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 08/09/23.
//

import Foundation
import SwiftUI

extension RatesFluctuationView {
    @MainActor class ViewModel: ObservableObject, RatesFluctuationDataProviderDelegate {
        @Published var ratesFluctuation = [RateFluctuationModel]()
        @Published var timeRange = TimeRangeEnum.today
        @Published var baseCurrency = "BRL"
        @Published var currencies = [String]()
        
        private let dataProvider: RatesFluctuationDataProvider?
        
        init(dataProvider: RatesFluctuationDataProvider = RatesFluctuationDataProvider()) {
            self.dataProvider = dataProvider
            self.dataProvider?.delegate = self
        }
        
        func doFetchTimeSeries(timeRange: TimeRangeEnum) {
            withAnimation {
                self.timeRange = timeRange
            }
            
            let startDate = timeRange.date.formatter(to: "yyyy-MM-dd")
            let endDate = Date().formatter(to: "yyyy-MM-dd")

            dataProvider?.fetchFlucutuation(by: baseCurrency,
                                            from: currencies,
                                            startDate: startDate,
                                            endDate: endDate)
        }
        
        nonisolated func success(model: [RateFluctuationModel]) {
            DispatchQueue.main.async {
                withAnimation {
                    self.ratesFluctuation = model.sorted {
                        $0.symbol < $1.symbol
                    }
                }
            }
        }
    }
}
