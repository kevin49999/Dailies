//
//  TODOsWidget.swift
//  TODOsWidget
//
//  Created by Kevin Johnson on 12/6/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodayEntry) -> ()) {
        // wot..
        let entry = TodayEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            var entries: [TodayEntry] = []
            let week = try loadCurrentWeek()

            for day in week {
                entries.append(.init(
                    date: day.dateCreated,
                    todos: day.todos,
                    configuration: ConfigurationIntent()
                ))
            }

            let timeline = Timeline(
                entries: entries,
                policy: .atEnd
            )
            completion(timeline)
        } catch {
            print(error)
        }
    }

    func loadCurrentWeek() throws -> [TodoList] {
        let url = AppGroup.todos.containerURL.appendingPathComponent("week")
        let data = try Data(contentsOf: url)
        let week = try JSONDecoder().decode([TodoList].self, from: data)
        week.forEach { print($0.name) }
        return week
    }
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let todos: [Todo]
    let configuration: ConfigurationIntent

    init(date: Date = Date.todayYearMonthDay(), todos: [Todo] = [], configuration: ConfigurationIntent) {
        self.date = date
        self.todos = todos
        self.configuration = configuration
    }
}

struct TODOsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.todos, id: \.self) { todo in
                Text(todo.text)
            }
        }
    }
}

@main
struct TODOsWidget: Widget {
    let kind: String = "TODOsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TODOsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TODOs for today")
        .description("Show the list of TODOs for today")
//        .supportedFamilies([])
    }
}

struct TODOsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TODOsWidgetEntryView(entry: TodayEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
