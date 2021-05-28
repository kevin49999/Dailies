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
        TodayEntry(date: Date(), today: TodoList(classification: .daysOfWeek), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodayEntry) -> ()) {
        let entry = TodayEntry(date: Date(), today: TodoList(classification: .daysOfWeek), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let week = try loadCurrentWeek()
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
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    // MARK: - Helper

    private func loadCurrentWeek() throws -> [TodoList] {
        let url = AppGroup.todos.containerURL.appendingPathComponent("week")
        let data = try Data(contentsOf: url)
        let week = try JSONDecoder().decode([TodoList].self, from: data)
        return week
    }
}

// MARK: - TodoEntry

struct TodayEntry: TimelineEntry {
    let date: Date
    let today: TodoList
    let configuration: ConfigurationIntent

    init(
        date: Date = Date(),
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
    let prefix: Int = 4

    var body: some View {
        if entry.today.incomplete.isEmpty {
            Text("Done ✅").bold()
        } else {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(entry.today.day)
                    .font(.headline)
                ForEach(entry.today.visible.prefix(prefix)
                        , id: \.self) { todo in
                    todo.completed ? Text("- \(todo.text)")
                        .strikethrough(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, color: .secondary)
                        .foregroundColor(.secondary) :
                        Text("- \(todo.text)")
                }
                entry.today.visible.count > prefix ?
                    Text("\(entry.today.incomplete.count - entry.today.visible.prefix(prefix).filter { !$0.completed }.count) more todo")
                    .font(.callout): nil
                Spacer()
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
}

// MARK: - TODOsWidget

@main
struct TODOsWidget: Widget {
    let kind: String = "TODOsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TODOsWidgetEntryView(entry: entry)
        }
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
                date: Date(),
                today: TodoList(
                    classification: .daysOfWeek,
                    todos: [
                        .init(text: "Go run"),
                        .init(text: "Derp"),
                        .init(text: "Study"),
                        .init(text: "Plerp"),
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
