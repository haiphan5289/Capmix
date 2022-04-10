//
//  Date+Extension.swift
//  EasyBaseAudio
//
//  Created by haiphan on 10/04/2022.
//

import Foundation
public extension Date {
    
    private static let formatDateDefault = DateFormatter()
    func string(from format: String = "dd/MM/yyyy") -> String {
        Date.formatDateDefault.locale = Locale(identifier: "en_US_POSIX")
        Date.formatDateDefault.dateFormat = format
        let result = Date.formatDateDefault.string(from: self)
        return result
    }
    
    func convertDateToLocalTime() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        return Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self)!
    }
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else {
            return "a moment ago"
            
        }
        
    }
}
