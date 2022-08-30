//
//  ContentView.swift
//  Shared
//
//  Created by 鑫磊 on 2022/8/26.
//

// 今天需要复习的日期列表（复习内容以日期为索引）

import SwiftUI

struct DailyItem: CustomStringConvertible {
    var date: Date
    var count: Int
    
    var description: String {
        "\(date.formatted(date: .numeric, time: .omitted)) (\(NumberFormatter.localizedString(from: NSNumber(value: count), number: .ordinal)))"
    }
}

struct ContentView: View {
    
    @State var startDate: Date = Date()
    @State var dailyRoutines: [DailyItem] = [DailyItem]()
    @State var resultString = ""
    
    let userDefaults = UserDefaults.standard
    @AppStorage("kStartDate") private var storedStartDate: TimeInterval = Date().timeIntervalSince1970
    
    var body: some View {
        DatePicker("Pick Start Date", selection: $startDate, in: ...Date(), displayedComponents:[.date]).onChange(of: startDate) { newValue in
            userDefaults.set(newValue.timeIntervalSince1970, forKey: "kStartDate")
            onSetStartDate(newValue)
            
        }.onAppear {
            startDate = Date(timeIntervalSince1970: storedStartDate)
            onSetStartDate(startDate)
        }
        // 今天所有需要复习的日期
        Text("routines:\n \(resultString)").frame(minHeight:168, alignment: .topLeading).foregroundColor(Color.orange)
    }
    
    func onSetStartDate(_ newStartDate: Date) {
        dailyRoutines = DailyRoutineHelper.getTodayRoutine(newStartDate, Date.now)
        resultString = dailyRoutines.reduce("", {x, item in
            x + "\(item)\n"
        })
    }
}

/*
 此后第1、3（+2）、6（+3）、13（+7）、28（+15）、59（+31）、122（+63）天需要复习
 124天前的内容不需要再复习了
 */
struct DailyRoutineHelper {
    static func getTodayRoutine(_ startDate: Date, _ today: Date) -> [DailyItem] {
        let kSecondsOfADay = 24 * 60 * 60
        let reviewDurations = [0, 1, 3, 6, 13, 28, 59, 122]
        
        var result: [DailyItem] = []
        for (index, durationDay) in reviewDurations.enumerated() {
            let date = today.advanced(by: TimeInterval(-durationDay * kSecondsOfADay))
            if (date < startDate) { break }
            result.insert(DailyItem(date: date, count: index), at: 0)
        }
        
        return result
    }
}
