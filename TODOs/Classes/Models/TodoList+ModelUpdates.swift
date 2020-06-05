//
//  TodoList+ModelUpdates.swift
//  TODOs
//
//  Created by Kevin Johnson on 5/12/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

// MARK: - Move

extension TodoList {

    enum MoveResult {
        case completedMovedToShowComplete
    }

    @discardableResult
    func move(sIndex: Int, dIndex: Int) -> MoveResult? {
        return move(sIndex: sIndex, destination: self, dIndex: dIndex)
    }

    @discardableResult
    func move(sIndex: Int, destination: TodoList, dIndex: Int) -> MoveResult? {
        let todo = remove(at: sIndex)
        return reinsert(todo: todo, destination: destination, index: dIndex)
    }
}

// MARK: - Remove

extension TodoList {

    @discardableResult
    func remove(at index: Int) -> Todo {
        let todo: Todo
        if showCompleted {
            todo = todos.remove(at: index)
            if let oIndex = incomplete.firstIndex(where: { $0 === todo }) {
                incomplete.remove(at: oIndex)
            }
        } else {
            todo = incomplete.remove(at: index)
            if let oIndex = todos.firstIndex(where: { $0 === todo }) {
                todos.remove(at: oIndex)
            }
        }
        return todo
    }
}

// MARK: - Reinsert

extension TodoList {

    @discardableResult
    func reinsert(todo: Todo, index: Int) -> MoveResult? {
        reinsert(todo: todo, destination: self, index: index)
    }

    @discardableResult
    func reinsert(todo: Todo, destination: TodoList, index: Int) -> MoveResult? {
        var result: MoveResult?
        if destination.showCompleted {
            destination.todos.insert(todo, at: index)
            incompleteComplementaryInsert(todo: todo, index: index, destination: destination)
        } else {
            destination.incomplete.insert(todo, at: index)
            todosComplementaryInsert(todo: todo, index: index, destination: destination)
            if todo.completed {
                // Moved completed todo to list not showing completed
                // ..for now will process move then delete
                result = .completedMovedToShowComplete
            }
        }
        return result
    }

    // MARK: - Complementary Inserts

    func todosComplementaryInsert(todo: Todo, index: Int) {
        todosComplementaryInsert(todo: todo, index: index, destination: self)
    }

    /// re-insert on all todos list when viewing incomplete
    func todosComplementaryInsert(
        todo: Todo,
        index: Int,
        destination: TodoList
    ) {
        var right: Todo?
        var left: Todo?
        if index - 1 >= 0 {
            left = destination.incomplete[index - 1]
        }
        if index + 1 < destination.incomplete.count {
            right = destination.incomplete[index + 1]
        }

        if let r = right {
            destination.todos.insert(todo, before: r, reference: destination.incomplete)
        } else if let l = left {
            destination.todos.insert(todo, after: l, reference: destination.incomplete)
        } else {
            destination.todos.append(todo)
        }
    }

    func incompleteComplementaryInsert(todo: Todo, index: Int) {
        incompleteComplementaryInsert(todo: todo, index: index, destination: self)
    }

    /// re-insert on incomplete list when viewing all todos
    func incompleteComplementaryInsert(
        todo: Todo,
        index: Int,
        destination: TodoList
    ) {
        guard !todo.completed else { return }

        var lIndex = index - 1
        var rIndex = index + 1
        var left: Todo?
        var right: Todo?
        while left == nil && right == nil && (lIndex >= 0 || rIndex < destination.todos.count) {
            if lIndex >= 0, !destination.todos[lIndex].completed {
                left = destination.todos[lIndex]
            }
            if rIndex < destination.todos.count, !destination.todos[rIndex].completed {
                right = destination.todos[rIndex]
            }
            lIndex -= 1
            rIndex += 1
        }

        if let r = right {
            destination.incomplete.insert(todo, before: r, reference: destination.todos)
        } else if let l = left {
            destination.incomplete.insert(todo, after: l, reference: destination.todos)
        } else {
            destination.incomplete.append(todo)
        }
    }
}

// MARK: - Toggle

extension TodoList {
    enum ToggleCompletedResult {
        case delete
        case reload
    }

    @discardableResult
    func toggleCompleted(index: Int) -> ToggleCompletedResult {
        if showCompleted {
            todos[index].completed.toggle()
            if todos[index].completed,
                let index = incomplete.firstIndex(where: { $0 === todos[index] })  {
                incomplete.remove(at: index)
            } else {
                incompleteComplementaryInsert(todo: todos[index], index: index, destination: self)
            }
            return .reload
        } else {
            assert(!incomplete[index].completed)
            incomplete[index].completed.toggle()
            incomplete.remove(at: index)
            return .delete
        }
    }
}

// MARK: - Add

extension TodoList {
    func add(todo: Todo) {
        todos.append(todo)
        incomplete.append(todo)
    }
}

// MARK: - General

extension Array where Element: AnyObject {
    mutating func insert(_ element: Element, after: Element, reference: Array) {
        var index: Int?
        if let i = reference.firstIndex(where: { $0 === after }) {
            index = i + 1
        }
        if let i = index {
            safelyInsert(element, at: i)
        } else {
            append(element)
        }
    }

    mutating func insert(_ element: Element, before: Element, reference: Array) {
        var index: Int?
        if let i = reference.firstIndex(where: { $0 === before }) {
            index = i - 1
        }
        if let i = index {
            safelyInsert(element, at: i)
        } else {
            append(element)
        }
    }

    mutating func safelyInsert(_ element: Element, at index: Index) {
        var mIndex = index
        if mIndex < 0 { mIndex = 0 }
        if mIndex > count { mIndex = count }
        insert(element, at: mIndex)
    }
}

extension Array where Element == Todo {
    func prettyPrint() {
        forEach { print($0.text, "completed:", $0.completed) }
        print("---")
    }
}
