//
//  ProcessModel.swift
//  CSCI51 Project
//
//  Created by Franco Velasco on 4/11/24.
//

import Foundation
import SwiftUI

class ProcessModel: Identifiable, Equatable {
    typealias RunTime = (start: Int, end: Int)
    var id: Int
    var arrivalTime: Int
    var turnaroundTime: Int
    var waitingTime: Int = 0
    var runningTimes: [Int] = []
    var publicTurnaroundTime: Int = 0
    var color: Color = .random()
    
    init(id: Int, arrivalTime: Int, turnaroundTime: Int) {
        self.id = id
        self.arrivalTime = arrivalTime
        self.turnaroundTime = turnaroundTime
    }
    
    init(id: Int) {
        self.id = id
        self.arrivalTime = 0
        self.turnaroundTime = 0
    }
    
    func addRunningTime(_ newTime: RunTime) {
        self.runningTimes.append(contentsOf: [newTime.start, newTime.end])
    }
    
    func resetModel() {
        self.waitingTime = 0
        self.runningTimes = []
    }
    
    static func ==(lhs: ProcessModel, rhs: ProcessModel) -> Bool {
        return lhs.id == rhs.id
    }
}
