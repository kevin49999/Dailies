//
//  TodoList+ModelUpdates.swift
//  TODOs
//
//  Created by Kevin Johnson on 5/12/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

extension TodoList {

    enum MoveResult {
        case completedMovedToShowComplete
    }

    @discardableResult
    func move(sIndex: Int, destination: TodoList, dIndex: Int) -> MoveResult? {
        let todo = remove(at: sIndex)
        return reinsert(todo: todo, destination: destination, index: dIndex)
    }

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

    func reinsert(todo: Todo, destination: TodoList, index: Int) -> MoveResult? {
        var result: MoveResult?
        if destination.showCompleted {
            destination.todos.insert(todo, at: index)
            incompleteInsert(todo: todo, index: index, destination: destination)
        } else {
            destination.incomplete.insert(todo, at: index)
            todosInsert(todo: todo, index: index, destination: destination)
            if todo.completed {
                // Moved completed todo to list not showing completed
                // ..for now will process move then delete
                result = .completedMovedToShowComplete
            }
        }
        return result
    }

    // TODO: Better naming for these inserts,, insertWhenNotVisible.. idk
    func todosInsert(
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

        if let r = right, let i = destination.todos.firstIndex(where: { $0 === r }) {
            destination.todos.insert(todo, at: i)
        } else if let l = left, let i = destination.todos.firstIndex(where: { $0 === l }) {
            destination.todos.insert(todo, at: i + 1)
        } else {
            destination.todos.append(todo)
        }
    }

    func incompleteInsert(
        todo: Todo,
        index: Int,
        destination: TodoList
    ) {
        guard !todo.completed else { return }
        
        var lIndex = index - 1
        var rIndex = index + 1
        var left: Todo?
        var right: Todo?
        while left == nil && right == nil {
            if lIndex >= 0, !destination.todos[lIndex].completed {
                left = destination.todos[lIndex]
            }
            if rIndex < destination.todos.count, !destination.todos[rIndex].completed {
                right = destination.todos[rIndex]
            }
            lIndex -= 1
            rIndex += 1
        }

        if let r = right, let i = destination.todos.firstIndex(where: { $0 === r }) {
            destination.incomplete.insert(todo, at: i)
        } else if let l = left, let i = destination.todos.firstIndex(where: { $0 === l }) {
            destination.incomplete.insert(todo, at: i + 1)
        } else {
            destination.incomplete.append(todo)
        }
    }

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
                // TODO: dbl check this..
                incompleteInsert(todo: todos[index], index: index, destination: self)
            }
            return .reload
        } else {
            assert(!incomplete[index].completed)
            incomplete[index].completed.toggle()
            incomplete.remove(at: index)
            return .delete
        }
    }

    // TODO: Def dbl check this too..
    func duplicate(index: Int) {
        let todo = visible[index]
        todo.completed = false
        if showCompleted {
            todos.insert(todo, at: index + 1)
            incompleteInsert(todo: visible[index], index: index, destination: self)
        } else {
            incomplete.insert(todo, at: index + 1)
            if let oIndex = todos.firstIndex(where: { $0 === visible[index] }) {
                todos.insert(todo, at: oIndex)
            }
        }
    }

    func add(todo: Todo) {
        todos.append(todo)
        incomplete.append(todo)
    }
}

extension Array where Element == Todo {
    func prettyPrint() {
        forEach { print($0.text, $0.completed) }
        print("---")
    }
}
