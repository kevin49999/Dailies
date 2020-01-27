//
//  TodoViewData.swift
//  TODOs
//
//  Created by Kevin Johnson on 1/26/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import Foundation

protocol TodoViewData {
    var text: String { get }
}

extension Todo: TodoViewData { }
