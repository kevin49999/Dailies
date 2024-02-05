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
        TodayEntry(
            date: Date.todayMonthDayYear(),
            today: TodoList(classification: .daysOfWeek),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodayEntry) -> ()) {
        let entry = TodayEntry(
            date: Date.todayMonthDayYear(),
            today: TodoList(classification: .daysOfWeek),
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let week = loadCurrentWeek()
        let entries: [TodayEntry] = week.map { .init(
            date: $0.dateCreated,
            today: $0,
            configuration: ConfigurationIntent()
        )}
        let timeline = Timeline(
            entries: entries,
            policy: .atEnd
        )
        completion(timeline)
    }

    // MARK: - Helper

    private func loadCurrentWeek() -> [TodoList] {
        let url = AppGroup.todos.containerURL.appendingPathComponent("week")
        do {
            let data = try Data(contentsOf: url)
            let week = try JSONDecoder().decode([TodoList].self, from: data)
            return week
        } catch {
            print("couldn't load current week:", error)
            print("could just not be cached yet, so return new")
            return TodoList.newDaysOfWeekTodoLists()
        }
    }
}

// MARK: - TodoEntry

struct TodayEntry: TimelineEntry {
    let date: Date
    let today: TodoList
    let configuration: ConfigurationIntent

    init(
        date: Date = Date.todayMonthDayYear(),
        today: TodoList,
        configuration: ConfigurationIntent
    ) {
        self.date = date
        self.today = today
        self.configuration = configuration
    }
}

// MARK: - TODOsWidgetEntryView

struct TODOsWidgetEntryView : View {
    var entry: Provider.Entry
    let prefix: Int = 3

    var body: some View {
        ZStack {
            Color(.secondarySystemGroupedBackground)
                .ignoresSafeArea()
            if entry.today.incomplete.isEmpty {
                Text("Done").bold()
            } else {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(entry.today.day)
                        .font(.body)
                        .bold()
                    ForEach(entry.today.visible.prefix(prefix)
                            , id: \.self) { todo in
                        todo.completed ? Text("- \(todo.text)")
                            .strikethrough(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, color: .secondary)
                            .foregroundColor(.secondary)
                            .font(.body)
                            .lineLimit(2):
                        Text("- \(todo.text)")
                            .font(.body)
                            .lineLimit(2)
                    }
                    entry.today.visible.count > prefix ?
                    Text("\(entry.today.incomplete.count - entry.today.visible.prefix(prefix).filter { !$0.completed }.count) more todo")
                        .font(.callout).bold() : nil
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal)
                .padding(.top)
            }
        }
        // https://stackoverflow.com/a/76842922
        .containerBackground(for: .widget, content: { Color.black })
    }
}

// MARK: - TODOsWidget

@main
struct TODOsWidget: Widget {
    let kind: String = "TODOsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TODOsWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("TODOs for today")
        .description("Show the list of TODOs for today")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

struct TODOsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TODOsWidgetEntryView(
            entry: TodayEntry(
                date: Date.todayMonthDayYear(),
                today: TodoList(
                    classification: .daysOfWeek,
                    todos: [
                        .init(text: "Go run"),
                        .init(text: "Yeet"),
                        .init(text: "Study"),
                        .init(text: "Derp"),
                        .init(text: "Movie"),
                        .init(text: "😇"),
                    ]
                ),
                configuration: ConfigurationIntent()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
