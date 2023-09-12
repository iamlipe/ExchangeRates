//
//  RateFluctuationDetailViewModel.swift
//  ExchangeRates
//
//  Created by Felipe Lima on 09/09/23.
//

import Foundation
import SwiftUI

extension RateFluctuationDetailView {
    @MainActor class ViewModel: ObservableObject, RatesFluctuationDataProviderDelegate, RatesHistoricalDataProviderDelegate {
        @Published var ratesFluctuation = [RateFluctuationModel]()
        @Published var ratesHistorical = [RateHistoricalModel]()
        @Published var timeRange = TimeRangeEnum.today
        @Published var baseCurrency: String?
        @Published var rateFluctuation: RateFluctuationModel?
        
        private var fluctuationDataProvider: RatesFluctuationDataProvider?
        private var historicalDataProvider: RatesHistoricalDataProvider?
                
        init(fluctuationDataProvider: RatesFluctuationDataProvider = RatesFluctuationDataProvider(),
             historicalDataProvider: RatesHistoricalDataProvider = RatesHistoricalDataProvider())
        {
            self.fluctuationDataProvider = fluctuationDataProvider
            self.historicalDataProvider = historicalDataProvider
            self.fluctuationDataProvider?.delegate = self
            self.historicalDataProvider?.delegate = self
        }
        
        func startStateView(baseCurrency: String, rateFluctuation: RateFluctuationModel, timeRage: TimeRangeEnum) {
            self.baseCurrency = baseCurrency
            self.rateFluctuation = rateFluctuation
            doFetchData(from: timeRage)
        }
        
        func doFetchData(from timeRange: TimeRangeEnum) {
            ratesFluctuation.removeAll()
            ratesHistorical.removeAll()
            
            withAnimation {
                self.timeRange = timeRange
            }
            
            doFetchRatesFluctuation()
            doFetchRetesHistorical(by: symbol)
        }
        
        func doComparation(with rateFluctuation: RateFluctuationModel) {
            self.rateFluctuation = rateFluctuation
            
            doFetchRetesHistorical(by: rateFluctuation.symbol)
        }
        
        func doFilter(by currency: String) {
            if let rateFluctuation = ratesFluctuation.filter({ $0.symbol == currency }).first {
                self.rateFluctuation = rateFluctuation
                doFetchRetesHistorical(by: rateFluctuation.symbol)
            }
        }
        
        private func doFetchRatesFluctuation() {
            if let baseCurrency {
                let startDate = timeRange.date.formatter(to: "YYYY-MM-dd")
                let endDate = Date().formatter(to: "YYYY-MM-dd")
                
                fluctuationDataProvider?.fetchFlucutuation(by: baseCurrency,
                                                           from: [],
                                                           startDate: startDate,
                                                           endDate: endDate)
            }
        }
        
        private func doFetchRetesHistorical(by currency: String) {
            if let baseCurrency {
                let startDate = timeRange.date.formatter(to: "YYYY-MM-dd")
                let endDate = Date().formatter(to: "YYYY-MM-dd")
                
                historicalDataProvider?.fetchTimeseries(by: baseCurrency,
                                                        from: currency,
                                                        startDate: startDate,
                                                        endDate: endDate)
            }
        }
    
        nonisolated func success(model: [RateFluctuationModel]) {
            DispatchQueue.main.async {
                self.rateFluctuation = model.filter({ $0.symbol == self.symbol }).first
                self.ratesFluctuation = model.filter({ $0.symbol != self.baseCurrency })
                    .sorted { $0.symbol < $1.symbol }
            }
        }
        
        nonisolated func success(model: [RateHistoricalModel]) {
            DispatchQueue.main.async {
                self.ratesHistorical = model.sorted { $0.period > $1.period }
            }
        }
        
        var title: String {
            return "\(baseCurrency ?? "") a \(symbol)"
            
        }
        
        var symbol: String {
            return rateFluctuation?.symbol ?? ""
        }
        
        var endRate: Double {
            return rateFluctuation?.endRate ?? 0.0
        }
        
        var changePct: Double {
            return rateFluctuation?.changePct ?? 0.0
        }
        
        var change: Double {
            return rateFluctuation?.change ?? 0.0
        }
        
        var changeDescription: String {
            switch timeRange {
            case .today:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 dia"
            case .thisWeek:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 7 dias"
            case .thisMonth:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 mês"
            case .thisSemester:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 6 meses"
            case .thisYear:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 ano"

            }
        }
            
        var hasRates: Bool {
            return ratesHistorical.filter { $0.endRate > 0 }.count > 0
        }
        
        var xAxisStride: Calendar.Component {
            switch timeRange {
            case .today:
                return .hour
            case .thisWeek:
                return .day
            case .thisMonth:
                return .day
            case .thisSemester:
                return .month
            case .thisYear:
                return .month
            }
        }
        
        var xAxisStrideCount: Int {
            switch timeRange {
            case .today:
                return 6
            case .thisWeek:
                return 2
            case .thisMonth:
                return 6
            case .thisSemester:
                return 2
            case .thisYear:
                return 3
            }
        }
            
        var yAxisMin: Double {
            let min = ratesHistorical.map { $0.endRate }.min() ?? 0.0
            return min - (min * 0.02)
        }
            
        var yAxisMax: Double {
            let max = ratesHistorical.map { $0.endRate }.max() ?? 0.0
            return max + (max * 0.02)
        }
            
        func xAxisLabelFormatStyle(for date: Date) -> String {
            switch timeRange {
            case .today:
                return date.formatter(to: "HH:mm")
            case .thisWeek:
                return date.formatter(to: "dd:MMM")
            case .thisMonth:
                return date.formatter(to: "MMM")
            case .thisSemester:
                return date.formatter(to: "MMM")
            case .thisYear:
                return date.formatter(to: "MMM, YYYY")
            }
        }
            
        func addFluctuation(fluctuation: RateFluctuationModel) {
            ratesFluctuation.insert(fluctuation, at: 0)
        }
            
        func removeFluctuation(fluctuation: RateFluctuationModel) {
            if let index = ratesFluctuation.firstIndex(of: fluctuation) {
                ratesFluctuation.remove(at: index)
            }
        }
    }
}
