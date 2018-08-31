 //
//  DateTime.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 24/08/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation


// MARK: operators

///REMARK: classes that inherit from NSObject use isEqual instead of ==   Extremamly important in case of using hashValue to index dictionary
public func ==(lhs: DateTime?, rhs: DateTime?) -> Bool {
    if let lhsDT = lhs, let rhsDT = rhs {
        return lhsDT.hashValue == rhsDT.hashValue
    }
    return false
}

public func ===(lhs: DateTime?, rhs: DateTime?) -> Bool {
    if let lhsDT = lhs, let rhsDT = rhs {
        return lhsDT.isEqualToDateTime(rhsDT)
    }
    return false
}

public func <(a: DateTime?, b: DateTime?) -> Bool {
    if let aDT = a, let bDT = b {
        return aDT.asNSDate.compare(bDT.asNSDate) == ComparisonResult.orderedAscending
    }
    return false
}

public func >(a: DateTime?, b: DateTime?) -> Bool {
    if let aDT = a, let bDT = b {
        return aDT.asNSDate.compare(bDT.asNSDate) == ComparisonResult.orderedDescending
    }
    return false
}

// MARK: class
// Date wrapper - holds all possible representations of date in one object
public final class DateTime: NSObject {
    
    // MARK: static properties
    public static let Calendar: NSCalendar = (Foundation.Calendar(identifier: .gregorian) as NSCalendar)
    public static let DatabaseLocale: Locale = Locale(identifier: "en_US")
    public static let ZeroDate = DateTime(fromDate: nil)
    public static var Now: DateTime {
        get {
            return DateTime(fromDate: Date())
        }
    }
    public static let Formats = [
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd HH:mm",
        "yyyy-MM-dd",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd HH:mm:ss Z",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  //ParsePush notifications has that format
    ]
    
    // MARK: properties
    public var asString: String?
    public var asNSDate: Date!
    public var asComponents: DateComponents!
    public var asInt: Int!
    public override var description: String {
        get {
            return "DateTime(\(self.localizedDateTimeWithTimeZone()))"
        }
    }
    public override var hashValue: Int {
        get {
            return self.asInt
        }
    }
    
    // MARK: lifecycle
    public init(fromComponents: DateComponents) {
        super.init()
        setDefaultValues()
        setComponents(fromComponents)
    }
    
    public init(fromString: String?, formats: [String] = DateTime.Formats) {
        super.init()
        setDefaultValues()
        setDateString(fromString, formats: formats)
    }
    
    public init(fromDate: Date? = nil) {
        super.init()
        setDefaultValues()
        setDate(fromDate)
    }
    
    public convenience init(fromDateTime: DateTime, copyItems: NSCalendar.Unit = []) {
        self.init(fromComponents: DateTime.Calendar.components(copyItems, from: fromDateTime.asNSDate))
    }
    
    public convenience init(fromTimeInterval: TimeInterval) {
        self.init(fromDate: Date(timeIntervalSince1970: fromTimeInterval))
    }
    
    // MARK: public methods
    public func getDay() -> DateTime {
        var comp = DateComponents()
        comp.year = self.asComponents.year
        comp.month = self.asComponents.month
        comp.day = self.asComponents.day
        comp.hour = 0
        comp.minute = 0
        
        return DateTime(fromComponents: comp)
    }
    
    fileprivate func setDefaultValues() {
        asNSDate = Date(timeIntervalSince1970: 0)
        asComponents = DateComponents()
        asComponents.day = 1
        asComponents.month = 1
        asComponents.year = 1
        asComponents.hour = 0
        asComponents.minute = 0
        asComponents.second = 0
        asComponents.nanosecond = 0
        asString = toLongString()
        asInt = componentsToInt(self.asComponents)
    }
    
    ///REMARK: classes that inherit from NSObject use isEqual instead of ==   Extremamly important in case of using hashValue to index dictionary
    public override func isEqual(_ object: Any?) -> Bool {
        if let secondObject = object as? DateTime  {
            return hashValue == secondObject.hashValue
        }
        return false
    }
    
}

// MARK: NSCoding
extension DateTime: NSCoding {
    
    @objc(encodeWithCoder:) public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.asNSDate)
    }
    
    convenience public init?(coder aDecoder: NSCoder) {
        if let date: Date = aDecoder.decodeObject() as? Date {
            self.init(fromDate: date)
        }
        else {
            return nil
        }
    }
    
}

// MARK: compare
extension DateTime {
    
    public func isEqualTime(_ otherDate: DateTime) -> Bool {
        if let h1 = asComponents.hour, let h2 = otherDate.asComponents.hour, (h1 == h2) {
            if let m1 = asComponents.minute, let m2 = otherDate.asComponents.minute, (m1 == m2) {
                return true
            }
        }
        return false
    }
    
    // only hours and minutes
    public func isEarlierOrEqualToday(_ otherDate: DateTime) -> Bool {
        if let h1 = asComponents.hour, let h2 = otherDate.asComponents.hour {
            if (h1 < h2) {
                return true
            }
            else if (h1 == h2) {
                if let m1 = asComponents.minute, let m2 = otherDate.asComponents.minute, (m1 <= m2) {
                    return true
                }
            }
        }
        return false
    }
    
    public func isLaterToday(_ otherDate: DateTime) -> Bool {
        if let h1 = asComponents.hour, let h2 = otherDate.asComponents.hour {
            if (h1 > h2) {
                return true
            }
            else if (h1 == h2) {
                if let m1 = asComponents.minute, let m2 = otherDate.asComponents.minute, (m1 > m2) {
                    return true
                }
            }
        }
        return false
    }
    
    // compartor
    public func isTheSameDay(_ otherDate: DateTime) -> Bool {
        if let y1 = asComponents.year, let y2 = otherDate.asComponents.year, (y1 == y2) {
            if let m1 = asComponents.month, let m2 = otherDate.asComponents.month, (m1 == m2) {
                if let d1 = asComponents.day, let d2 = otherDate.asComponents.day, (d1 == d2) {
                    return true
                }
            }
        }
        return false
    }
    
    public func isEqualToDate(_ dateToCompare: Date) -> Bool {
        return self.asNSDate.compare(dateToCompare) == ComparisonResult.orderedSame
    }
    
    public func isEqualToDateTime(_ dateTimeToCompare: DateTime) -> Bool {
        return isEqualToDate(dateTimeToCompare.asNSDate)
    }
    
    public func isBeforeDateTime(_ dateTime: DateTime) -> Bool {
        return isWhenInTime(dateTime, <)
    }
    
    public func isBeforeNow() -> Bool {
        return isBeforeDateTime(DateTime(fromDate: Date()))
    }
    
    public func isAfterDateTime(_ dateTime: DateTime) -> Bool {
        return isWhenInTime(dateTime, >)
    }
    
    public func isAfterNow() -> Bool {
        return isAfterDateTime(DateTime(fromDate: Date()))
    }
    
    public func isWhenInTime(_ dateTime: DateTime, _ compareCallback: (_ first: DateTime, _ second: DateTime) -> Bool) -> Bool {
        return compareCallback(self, dateTime)
    }
}

// MARK: datetime modifiers
extension DateTime {
    
    public func setDate(_ year: Int = 0, month: Int = 0, day: Int = 0) {
        asComponents.year = year
        asComponents.month = month
        asComponents.day = day
        setComponents(asComponents)
    }
    
    public func setTime(hour: Int = 0, minute: Int = 0, second: Int = 0) {
        asComponents.hour = hour
        asComponents.minute = minute
        asComponents.second = second
        setComponents(asComponents)
    }
    
    public func setTimeZone(_ timeZone: TimeZone?) {
        if let tz = timeZone {
            asComponents.timeZone = tz
            setComponents(asComponents)
        }
    }
    
    public func setComponents(_ components: DateComponents?) {
        if let comp = components {
            self.asComponents = comp
            self.asNSDate = DateTime.Calendar.date(from: comp)!
            self.asInt = componentsToInt(comp)
            self.asString = nil
        }
    }
    
    public func setDate(_ date: Date?) {
        if let d = date {
            self.asNSDate = d
            self.asComponents = DateTime.Calendar.components([.year, .month, .day, .hour, .minute, .second, .timeZone], from: d)
            self.asInt = componentsToInt(self.asComponents)
            self.asString = nil
        }
    }
    
    public func setDateString(_ dateString: String?, formats: [String] = DateTime.Formats) {
        if let ds = dateString {
            setDate(parseDate(ds, formats: formats))
            self.asString = ds
        }
    }
    
    fileprivate func componentsToInt(_ dateComp:DateComponents) -> Int {
        let year = dateComp.year ?? 0
        let month = dateComp.month ?? 0
        let day = dateComp.day ?? 0
        
        return year * 10000 + month * 100 + day
    }
    
    public func parseDate(_ dateString: String?, formats: [String] = DateTime.Formats) -> Date {
        if let ds = dateString {
            let formatter = DateFormatter()
            for format in formats {
                formatter.dateFormat = format
                formatter.locale = DateTime.DatabaseLocale
                if let date = formatter.date(from: ds) {
                    return date
                }
                
            }
        }
        return Date(timeIntervalSince1970: 0)
    }
    
    public func dateTimeByAddingTimeInterval(_ value: TimeInterval) -> DateTime {
        let newDate = asNSDate.addingTimeInterval(value)
        let dateTime = DateTime(fromDate: newDate)
        return dateTime
    }
    
}

// MARK: formatting
extension DateTime {
    
    // how many minutes elapsed from the beginning of the day
    public func minutesFromMidnight() -> Int {
        if let hour = asComponents.hour, let minute = asComponents.minute {
            return hour * 60 + minute
        }
        return 0
    }
    
    public func minutesFromDateTime(_ otherDate: DateTime) -> Int {
        let h1 = otherDate.asComponents.hour ?? 0
        let h2 = self.asComponents.hour ?? 0
        let min1 = otherDate.asComponents.minute ?? 0
        let min2 = self.asComponents.minute ?? 0
        
        return (h2 * 60 + min2) - (h1 * 60 + min1)
    }
    
    // sql format
    public func dayStartInSqlFormat() -> String {
        return format("yyyy-MM-dd 00:00:00")
    }
    
    public func dayEndInSqlFormat() -> String {
        return format("yyyy-MM-dd 23:59:59")
    }
    
    public func toDateString() -> String {
        return format("yyyy-MM-dd")
    }
    
    public func toTimeString() -> String {
        return format("HH:mm:ss")
    }
    
    public func toLongString() -> String {
        return format("yyyy-MM-dd HH:mm:ss")
    }
    
    public func toYearMonthString() -> String {
        return format("yyyy-MM")
    }
    
}

// MARK: i18n
extension DateTime {
    public func unixEpochTime() -> Int {
        let t = self.asNSDate.timeIntervalSince1970
        return Int(t)
    }
    
    
    public func format(_ dateFormat: String, locale: Locale? = DateTime.DatabaseLocale) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let locale = locale {
            formatter.locale = locale
        }
        return formatter.string(from: self.asNSDate)
    }
    
    public func localizedDateTime() -> String {
        return format("yyyy-MM-dd HH:mm:ss", locale: nil)
    }
    
    public func localizedDateTimeWithTimeZone() -> String {
        return format("yyyy-MM-dd HH:mm:ss Z", locale: nil)
    }
    
    public func localizedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter.string(from: self.asNSDate)
    }
    
    public func localizedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: self.asNSDate)
    }
    
    public func localizedWeekday() -> String {
        return format("EEEE", locale: nil)
    }
    
    public func localizedWeekdayShort() -> String {
        return format("EE", locale: nil)
    }
    
    public func localizedMonthAndYear() -> String {
        return format("MMMM yyyy", locale: nil)
    }
    
    public func localizedDay() -> String {
        return format("dd", locale: nil)
    }
    
    public static func localizedTime(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> String {
        let dt = DateTime()
        dt.setTime(hour: hours, minute: minutes, second: seconds)
        return dt.localizedTime()
    }
    
}
