//
//  ContentView.swift
//  Shared
//
//  Created by 鑫磊 on 2022/8/26.
//

// 今天需要复习的日期列表（复习内容以日期为索引）

import SwiftUI

#if os(iOS)
typealias Application = UIApplication
let DailyRoutineShotcut = "DailyRoutine(iOS16)"
#elseif os(macOS)
typealias Application = NSWorkspace
let DailyRoutineShotcut = "DailyRoutine"
#endif

struct DailyItem: CustomStringConvertible {
    var date: Date
    var count: Int
    
    var formatedDate: String {
        return date.formatted(date: .numeric, time: .omitted)
    }
    
    var formatedCount: String {
        if count == 0 {
            return "Today"
        }
        return NumberFormatter.localizedString(from: NSNumber(value: count), number: .ordinal)
    }
    
    var description: String {
        return formatedDate + " " + formatedCount
    }
}

struct ContentView: View {
    
    @State var startDate: Date = Date()
    @State var dailyRoutines: [DailyItem] = [DailyItem]()
    
    let userDefaults = UserDefaults.standard
    @AppStorage("kStartDate") private var storedStartDate: TimeInterval = Date().timeIntervalSince1970
    
    var body: some View {
        VStack() {
            Spacer()
            // 今天所有需要复习的日期
            List {
                Section {
                    ForEach(dailyRoutines, id:\.date) { item in
                        Button {
                            let noteName = item.formatedDate
                            let url = URL(string:"shortcuts://run-shortcut?name=\(DailyRoutineShotcut)&input=\(noteName)")!
                            Application.shared.open(url)
                        } label: {
                            Text(item.formatedDate + " ")
                            +
                            Text(item.formatedCount)
                                .foregroundColor(item.count == 0 ? Color.orange : Color.gray)
                                .font(.footnote)
                        }.opacity(item.count == 0 ? 0.6 : 1.0)
                    }
                } header: {
                    Text("Today's review list")
                }

            }.listStyle(.plain)
            
            Spacer()
            DatePicker("Pick Start Date", selection: $startDate, in: ...Date(), displayedComponents:[.date]).onChange(of: startDate) { newValue in
                userDefaults.set(newValue.timeIntervalSince1970, forKey: "kStartDate")
                onSetStartDate(newValue)
                
            }.onAppear {
                startDate = Date(timeIntervalSince1970: storedStartDate)
                onSetStartDate(startDate)
            }.frame(maxWidth: 300)
        }
    }
    
    func onSetStartDate(_ newStartDate: Date) {
        dailyRoutines = DailyRoutineHelper.getTodayRoutine(newStartDate, Date.now)
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

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        return Group {
            ContentView().previewDevice("iPad mini (6th generation)").preferredColorScheme(.dark).previewInterfaceOrientation(.portraitUpsideDown)
            ContentView().preferredColorScheme(.dark)
        }
    }
}
