//
//  EnvironmentViewModel.swift
//  CSCI51 Project
//
//  Created by Franco Velasco on 4/12/24.
//

import Foundation

class EnvironmentViewModel: ObservableObject {
    @Published var processCount: Int = 0 
    @Published var schedulingAlgorithm: InternalSchedulingAlgorithm = .sjf
    @Published var timeQuantum: Int = 0
    
    @Published var processList: [ProcessModel] = []
    @Published var averageWaitingTime: Double? = nil
    
    @Published var timelineView: TimelineOptions = .split_process
    @Published var processRunningAtTime: [Int: Int] = [:]
    
    var lastRuntime: Int = 0
    
    func calculateTimeline() {
        // Reset the values within the model
        self.averageWaitingTime = nil
        self.processRunningAtTime = [:]
        self.lastRuntime = 0
        
        for process in processList {
            process.turnaroundTime = process.publicTurnaroundTime
            process.resetModel()
        }
        
        let sortedProcesses = processList.sorted { lhs, rhs in
            // Sort the processes by their arrival times, then by their turnaround times
            if lhs.arrivalTime == rhs.arrivalTime {
                return lhs.turnaroundTime < rhs.turnaroundTime
            }
            
            return lhs.arrivalTime < rhs.arrivalTime
        }
        
        var processByArrivalTimes: [Int: [ProcessModel]] = [:]
        for process in sortedProcesses {
            processByArrivalTimes[process.arrivalTime, default: []].append(process)
        }
        
        var currentTime = 0
        if schedulingAlgorithm == .sjf {
            var startTime: Int = currentTime
            var currentProcess: ProcessModel? = nil
            var waitingProcesses: [ProcessModel] = []
            var numOfRemainingProcesses: Int = sortedProcesses.count
            
            while numOfRemainingProcesses > 0 {
                if let processesAtArrivalTime = processByArrivalTimes[currentTime] {
                    // Add any processes that have arrived to waiting queue
                    waitingProcesses.append(contentsOf: processesAtArrivalTime)
                } else if waitingProcesses.count == 0 {
                    // No waiting processes currently in or to be added, so move to next time
                    currentTime += 1
                    startTime = currentTime
                    continue
                }
                
                waitingProcesses.sort { lhs, rhs in
                    lhs.turnaroundTime < rhs.turnaroundTime
                }
                
                let newProcess = waitingProcesses.first
                if newProcess != currentProcess {
                    // Context switch
                    currentProcess?.addRunningTime((startTime, currentTime))
                    startTime = currentTime
                    currentProcess = newProcess
                }
                
                currentTime += 1
                currentProcess?.turnaroundTime -= 1
                
                if currentProcess?.turnaroundTime == 0 {
                    // Process has become spent
                    currentProcess?.addRunningTime((startTime, currentTime))
                    waitingProcesses.removeProcess(currentProcess)
                    currentProcess = nil
                    numOfRemainingProcesses -= 1
                }
            }
            
        } else if schedulingAlgorithm == .round_robin {
            var startTime: Int = currentTime
            var waitingProcesses: [ProcessModel] = []
            var numOfRemainingProcesses: Int = sortedProcesses.count
            
            var quantumTimer = timeQuantum
            var waitingProcessIndex = 0
            
            while numOfRemainingProcesses > 0 {
                if let processesAtArrivalTime = processByArrivalTimes[currentTime] {
                    // Add any processes that have arrived to waiting queue
                    waitingProcesses.append(contentsOf: processesAtArrivalTime)
                    processByArrivalTimes.removeValue(forKey: currentTime)
                    
                    // Add those coming at the next time
                    if let nextProcesses = processByArrivalTimes[currentTime + 1] {
                        waitingProcesses.append(contentsOf: nextProcesses)
                        processByArrivalTimes.removeValue(forKey: currentTime + 1)
                    }
                } else if waitingProcesses.count == 0 {
                    // No waiting processes currently in or to be added, so move to next time
                    currentTime += 1
                    startTime = currentTime
                    continue
                }
                
                // Reset waiting index if it overflows beyond list indices
                waitingProcessIndex = waitingProcessIndex < waitingProcesses.count ? waitingProcessIndex : 0
                
                
                // Run process for the moment
                currentTime += 1
                quantumTimer -= 1
                waitingProcesses[waitingProcessIndex].turnaroundTime -= 1
                
                if waitingProcesses[waitingProcessIndex].turnaroundTime == 0 {
                    // Process is spent, remove from queue
                    // For this implementation, the time quantum does not get reset
                    waitingProcesses[waitingProcessIndex].addRunningTime((startTime, currentTime))
                    waitingProcesses.remove(at: waitingProcessIndex)
                    numOfRemainingProcesses -= 1
                    startTime = currentTime
                    
                    // Handle the quantum timer in a special case here
                    // No need for a context switch since we've done so with the above
                    if quantumTimer == 0 {
                        quantumTimer = timeQuantum
                        continue
                    }
                }
                
                if quantumTimer == 0 {
                    // Reset quantum timer, context switch
                    waitingProcesses[waitingProcessIndex].addRunningTime((startTime, currentTime))
                    startTime = currentTime
                    
                    waitingProcessIndex += 1
                    quantumTimer = timeQuantum
                    
                }
            }
        }
        
        lastRuntime = currentTime
        
        // Waiting time calculations
        var totalWaitingTime: Double = 0
        for process in sortedProcesses {
            // Include the arrival time, that factors into the waiting time
            var times = [process.arrivalTime]
            times.append(contentsOf: process.runningTimes)
            
            for i in stride(from: 0, to: times.count - 1, by: 2) {
                let prevEndTime = times[i]
                let nextStartTime = times[i + 1]
                
                totalWaitingTime += Double(nextStartTime - prevEndTime)
            }
            
            // Running time calculations
            for i in stride(from: 1, to: times.count - 1, by: 2) {
                let startTime = times[i]
                let endTime = times[i + 1]
                
                for j in startTime..<endTime {
                    processRunningAtTime[j] = process.id
                }
            }
        }
        
        self.averageWaitingTime = totalWaitingTime / Double(processCount)
    }
    
    func resetModel() {
        self.processCount = 0
        self.schedulingAlgorithm = .sjf
        self.timeQuantum = 0
        
        self.processList = []
        self.averageWaitingTime = nil
        
        self.processRunningAtTime = [:]
    }
    enum InternalSchedulingAlgorithm: CaseIterable, Identifiable {
        var id: String { self.title }
        
        case sjf, round_robin
        
        var title: String {
            switch self {
                case .sjf:
                    return "Shortest Job First - Preemptive"
                case .round_robin:
                    return "Round Robin (Time Quantum Required)"
            }
        }
    }
    
    enum TimelineOptions: String, CaseIterable {
        case single_timeline = "Single Timeline", split_process = "Split Processes"
    }
}

extension Array where Array.Element == ProcessModel {
    mutating func removeProcess(_ process: ProcessModel?) {
        guard var process else { return }
        
        self.removeAll { model in
            model == process
        }
    }
}


