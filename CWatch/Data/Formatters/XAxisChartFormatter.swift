//
//  XAxisValueFormatter.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import Foundation
import Charts

class XAxisChartFormatter: IndexAxisValueFormatter {
    private var dateFormatter : DateFormatter?
    private var timeValues: [TimeInterval]?
    
    convenience init(dateFormatter: DateFormatter, dateValues: [TimeInterval]) {
        self.init()
        self.dateFormatter = dateFormatter
        self.timeValues = dateValues
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter, let datedIntervals = timeValues else {
            return ""
        }
        
        let date = Date(timeIntervalSince1970: datedIntervals[Int(value)] )
        return dateFormatter.string(from: date)
    }
}

