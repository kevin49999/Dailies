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

    func move(sIndex: Int, destination: TodoList, dIndex: Int) -> MoveResult? {
        let todo = remove(at: sIndex)
        let result = reinsert(todo: todo, destination: destination, index: dIndex)
        return result
    }

    @discardableResult
    func remove(at index: Int) -> Todo {
        let todo: Todo
        if showCompleted {
            todo = todos.remove(at: index)
            if !todo.completed, let oIndex = incomplete.firstIndex(where: { $0 === todo }) {
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
            let neighbor: Todo?
            if self == destination {
                // Just removed need to not insert out of bounds at end
                neighbor = destination.todos[min(index, destination.todos.count - 1)]
            } else {
                switch index {
                case 0:
                    neighbor = destination.todos.count > 0 ? destination.todos[0] : nil
                case destination.incomplete.count:
                    neighbor = destination.todos.count > 0 ? destination.todos[index - 1] : nil
                default:
                    neighbor = destination.todos.count > 0 ? destination.todos[index] : nil
                }            }
            destination.todos.insert(todo, at: index)
            incompleteInsert(neighbor: neighbor, todo: todo, destination: destination, at: index)

        } else {
            let neighbor: Todo?
            if self == destination {
                neighbor = destination.incomplete[min(index, destination.incomplete.count - 1)]
            } else {
                switch index {
                case 0:
                    neighbor = destination.incomplete.count > 0 ? destination.incomplete[0] : nil
                case destination.incomplete.count:
                    neighbor = destination.incomplete.count > 0 ? destination.incomplete[index - 1] : nil
                default:
                    neighbor = destination.incomplete.count > 0 ? destination.incomplete[index] : nil
                }
            }
            destination.incomplete.insert(todo, at: index)
            if todo.completed {
                // Moved completed todo to list not showing completed
                // ..for now will process move then delete
                result = .completedMovedToShowComplete
            }
            if let n = neighbor, let oIndex = destination.todos.firstIndex(where: { $0 === n }) {
                destination.todos.insert(todo, at: oIndex)
            } else {
                destination.todos.append(todo)
            }
        }
        return result
    }

    func incompleteInsert(
        neighbor: Todo? = nil,
        todo: Todo,
        destination: TodoList,
        at index: Int
    ) {
        if let n = neighbor, !n.completed, let oIndex = destination.incomplete.firstIndex(where: { $0 === n }) {
            destination.incomplete.insert(todo, at: oIndex)
        } else {
            // Find nearest incomplete to the left in main list
            var i = index - 1
            var lTodo: Todo?
            while i >= 0 && lTodo == nil {
                if !destination.todos[i].completed {
                    lTodo = destination.todos[i]
                } else {
                    i -= 1
                }
            }
            // Insert in incomplete right after that item occurs in incomplete
            if let l = lTodo, let oIndex = destination.incomplete.firstIndex(where: { $0 === l }) {
                destination.incomplete.insert(todo, at: oIndex + 1)
            } else {
                destination.incomplete.insert(todo, at: 0)
            }
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
