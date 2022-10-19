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
#elseif os(macOS)
typealias Application = NSWorkspace
#endif
let DailyRoutineShortcut = "DailyRoutine_Old"
let DailyRoutineShortcut_iOS16 = "DailyRoutine"


struct DailyItem: CustomStringConvertible {
    var date: Date
    var count: Int
    
    var formatedDate: String {
        return date.formatted(date: .numeric, time: .omitted)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    var formatedCount: String {
        if isToday {
            return "Today"
        }
        return NumberFormatter.localizedString(from: NSNumber(value: count), number: .ordinal)
    }
    
    var description: String {
        return formatedDate + " " + formatedCount
    }
}

extension DailyItem : Hashable {
    var hashValue: Int {
        return date.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}

struct ContentView: View {
    
    @State var startDate: Date = Date()
    @State var showYesterday = false
    @State var dailyRoutines: [DailyItem] = [DailyItem]()
    @State var clickedItems = Set<DailyItem>()
    
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
                            clickedItems.insert(item)
                            let noteName = item.formatedDate
                            var shortcutName = DailyRoutineShortcut
#if os(iOS)
                            if #available(iOS 16, *) {
                                shortcutName = DailyRoutineShortcut_iOS16
                            }
#endif
                            let url = URL(string:"shortcuts://run-shortcut?name=\(shortcutName)&input=\(noteName)")!
                            Application.shared.open(url)
                        } label: {
                            Text(item.formatedDate + " ")
                            +
                            Text(item.formatedCount)
                                .foregroundColor(item.isToday ? Color.orange : Color.gray)
                                .font(.footnote)
                        }.opacity(item.isToday || clickedItems.contains(item) ? 0.6 : 1.0)
                    }
                } header: {
                    Text("\(showYesterday ? "Yesterday" : "Today")'s review list")
                }

            }.listStyle(.plain)
            
            Spacer()
            
            Toggle("Review Yesterday", isOn: $showYesterday).onChange(of: showYesterday) { newValue in
                updateDalyRoutines(startDate, newValue)
            }.padding()
            
            Spacer()
            DatePicker("Pick Start Date", selection: $startDate, in: ...Date(), displayedComponents:[.date]).onChange(of: startDate) { newValue in
                userDefaults.set(newValue.timeIntervalSince1970, forKey: "kStartDate")
                updateDalyRoutines(newValue, showYesterday)
                
            }.onAppear {
                startDate = Date(timeIntervalSince1970: storedStartDate)
                updateDalyRoutines(startDate, showYesterday)
            }.frame(maxWidth: 300)
        }
    }
    
    func updateDalyRoutines(_ newStartDate: Date, _ showYesterday: Bool) {
        var reviewDate = Date.now
        if (showYesterday) {
            reviewDate = reviewDate.advanced(by: -1 * 24 * 60 * 60)
        }
        dailyRoutines = DailyRoutineHelper.getRoutine(newStartDate, reviewDate)
    }
}

/*
 此后第1、3（+2）、6（+3）、13（+7）、28（+15）、59（+31）、122（+63）天需要复习
 124天前的内容不需要再复习了
 */
struct DailyRoutineHelper {
    static func getRoutine(_ startDate: Date, _ reviewDate: Date) -> [DailyItem] {
        let kSecondsOfADay = 24 * 60 * 60
        let reviewDurations = [0, 1, 3, 6, 13, 28, 59, 122]
        
        var result: [DailyItem] = []
        for (index, durationDay) in reviewDurations.enumerated() {
            let date = reviewDate.advanced(by: TimeInterval(-durationDay * kSecondsOfADay))
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
