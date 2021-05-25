//
//  DateUtils.swift
//  AdminSchoolFestivalNavi
//
//  Created by 西田翔平 on 2020/05/05.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import Foundation

class DateUtils {
    
    class func dateFromString(string: String, dateFormat: String) -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = dateFormat
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
    
    class func sortDateNewtoOld(dateArray: [Date], temperatureArray: [String]) -> ([Date], [String]) {
        var sortedDateList:[Date] = []
        var sortedTemperatureList:[String] = []

        let dateSorted = dateArray.enumerated().sorted { $1.element < $0.element }

        for indexPathRow in 0..<dateArray.count {
            //並べ替えた後のタプルからindex番号(offset)を取り出す
            let originalIndex = dateSorted[indexPathRow]
            sortedDateList.append(dateArray[originalIndex.offset])
            sortedTemperatureList.append(temperatureArray[originalIndex.offset])
        }
        return(sortedDateList, sortedTemperatureList)
    }
    
    class func sortDateOldtoNew(dateArray: [Date], temperatureArray: [String]) -> ([Date], [String]) {
        var sortedDateList:[Date] = []
        var sortedTemperatureList:[String] = []

        let dateSorted = dateArray.enumerated().sorted { $0.element < $1.element }

        for indexPathRow in 0..<dateArray.count {
            //並べ替えた後のタプルからindex番号(offset)を取り出す
            let originalIndex = dateSorted[indexPathRow]
            sortedDateList.append(dateArray[originalIndex.offset])
            sortedTemperatureList.append(temperatureArray[originalIndex.offset])
        }
        return(sortedDateList, sortedTemperatureList)
    }
    
    class func formatToText(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
