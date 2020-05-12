//
//  TodoList+ModelUpdates.swift
//  TODOs
//
//  Created by Kevin Johnson on 5/12/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

extension TodoList {
    func move(sIndex: Int, destination: TodoList, dIndex: Int) {
        let todo = remove(at: sIndex)
        reinsert(todo: todo, destination: destination, index: dIndex)
    }

    @discardableResult
    func remove(at index: Int) -> Todo {
        let todo: Todo
        if showCompleted {
            todo = todos.remove(at: index)
            // TODO: Could move to background..
            if !todo.completed, let oIndex = incomplete.firstIndex(where: { $0 === todo }) {
                incomplete.remove(at: oIndex)
            }
        } else {
            todo = incomplete.remove(at: index)
            // ""
            if let oIndex = todos.firstIndex(where: { $0 === todo }) {
                todos.remove(at: oIndex)
            }
        }
        return todo
    }

    func reinsert(todo: Todo, destination: TodoList, index: Int) {
        if destination.showCompleted {
            let other: Todo?
            if self === destination {
                // Just removed need to not insert out of bounds at end
                other = destination.todos[min(index, destination.todos.count - 1)]
            } else {
                other = destination.todos.count > 0 ? destination.todos[index - 1] : nil
            }
            destination.todos.insert(todo, at: index)
            incompleteInsert(neighbor: other, todo: todo, destination: destination, at: index)

        } else {
            let other: Todo?
            if self === destination {
                // ""
                other = destination.incomplete[min(index, destination.incomplete.count - 1)]
            } else {
                other = destination.incomplete.count > 0 ? destination.incomplete[index - 1] : nil
            }
            destination.incomplete.insert(todo, at: index)

            // TODO: ""
            if let o = other, let oIndex = destination.todos.firstIndex(where: { $0 === o }) {
                destination.todos.insert(todo, at: oIndex)
            }
        }
    }

    func incompleteInsert(
        neighbor: Todo? = nil,
        todo: Todo,
        destination: TodoList,
        at index: Int
    ) {
        // TODO: Also could be background work, not visible in UI
        if let n = neighbor, let oIndex = destination.incomplete.firstIndex(where: { $0 === n }) {
            destination.incomplete.insert(todo, at: oIndex)
        } else {
            // Find nearest incomplete to the left in completed list, and insert there.
            var i = index - 1
            var lTodo: Todo?
            while i >= 0 && lTodo == nil {
                if !destination.todos[i].completed {
                    lTodo = destination.todos[i]
                } else {
                    i -= 1
                }
            }
            if let l = lTodo, let oIndex = destination.incomplete.firstIndex(where: { $0 === l }) {
                destination.incomplete.insert(todo, at: oIndex + 1)
            } else {
                destination.incomplete.insert(todo, at: 0)
            }
        }
    }

    enum MarkCompletedResult {
        case delete
        case reload
    }

    @discardableResult
    func toggleCompleted(index: Int) -> MarkCompletedResult {
        if showCompleted {
            todos[index].completed.toggle()
            if todos[index].completed,
                let index = incomplete.firstIndex(where: { $0 === todos[index] })  {
                incomplete.remove(at: index)
            } else {
                // re-add
                incompleteInsert(todo: todos[index], destination: self, at: index)
            }
            return .reload
        } else {
            assert(!incomplete[index].completed)
            incomplete[index].completed.toggle()
            incomplete.remove(at: index)
            return .delete
        }
    }

    func duplicate(index: Int) {
        let todo = visible[index]
        todo.completed = false
        if showCompleted {
            todos.insert(todo, at: index + 1)
            incompleteInsert(todo: visible[index], destination: self, at: index)
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
        forEach { print($0.text, $0.completed)}
        print("---")
    }
}
