//
//  ProcessInputView.swift
//  CSCI51 Project
//
//  Created by Franco Velasco on 4/11/24.
//

import SwiftUI

@available(macOS 14, *)
struct ProcessInputView: View {
    @EnvironmentObject var environment: EnvironmentViewModel
    
    @State var showProcessList: Bool = false
    @State var errors: Set<InputErrors> = Set<InputErrors>()
    
    var body: some View {
        Grid(verticalSpacing: 16) {
            GridRow {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scheduling Algorithm")
                        .font(.title3)
                    Picker(selection: $environment.schedulingAlgorithm.animation()) {
                        ForEach(EnvironmentViewModel.InternalSchedulingAlgorithm.allCases, id: \.self) { algo in
                            Text(algo.title)
                                .id(algo)
                        }
                    } label: {
                        EmptyView()
                    }
                }
            }
            .gridCellColumns(2)
            
            if environment.schedulingAlgorithm == .round_robin {
                GridRow {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time Quantum")
                            .font(.title3)
                        TextField("Positive Integers only!", value: $environment.timeQuantum, formatter: NumberFormatter())
                        if errors.contains(.invalidTimeQuantum) {
                            Label("Must be a positive integer", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.caption)
                        }
                        
                    }
                }
                .gridCellColumns(2)
            }
            
            GridRow(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Number of Processes")
                        .font(.title3)
                    TextField("Positive Integers only!", value: $environment.processCount, formatter: NumberFormatter())
                    if errors.contains(.invalidProcessCount) {
                        Label("Must be a positive integer", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.yellow)
                            .font(.caption)
                    }
                }
                
                Button("Confirm") {
                    withAnimation {
                        self.showProcessList = false
                    }
                    
                    // Protect against invalid process counts
                    self.errors.remove(.invalidProcessCount)
                    guard environment.processCount > 0 else {
                        self.errors.insert(.invalidProcessCount)
                        return
                    }
                    
                    let (oldCount, newCount) = (environment.processList.count, environment.processCount)
                    
                    if oldCount < newCount {
                        // Need to add new process model entities into the list
                        for i in 0..<(newCount - oldCount) {
                            environment.processList.append(
                                ProcessModel(id: oldCount + i)
                            )
                        }
                    } else if oldCount > newCount {
                        // Remove the last entities in the process until newCount is met
                        environment.processList.removeLast(oldCount - newCount)
                    }
                    
                    withAnimation {
                        self.showProcessList = true
                    }
                }
            }
            
            if showProcessList {
                if environment.processList.count <= 4 {
                    ForEach($environment.processList, id: \.id) { $process in
                        GridRow {
                            VStack(alignment: .leading) {
                                Text("Process \(process.id + 1)")
                                    .font(.title3)
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Arrival Time")
                                        TextField("Whole Numbers only!", value: $process.arrivalTime, formatter: NumberFormatter())
                                        if errors.contains(.invalidArrivalTime(id: process.id)) {
                                            Label("Must be a whole number", systemImage: "exclamationmark.triangle.fill")
                                                .foregroundStyle(Color.yellow)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Turnaround Time")
                                        TextField("Positive Integers only!", value: $process.publicTurnaroundTime, formatter: NumberFormatter())
                                        if errors.contains(.invalidArrivalTime(id: process.id)) {
                                            Label("Must be a positive integer", systemImage: "exclamationmark.triangle.fill")
                                                .foregroundStyle(Color.yellow)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                        .gridCellColumns(2)
                        .id("Process-\(process.id)")
                        .padding(8)
                        .background(Color(NSColor.darkGray))
                        .cornerRadius(8)
                    }
                } else {
                    ScrollView {
                        ForEach($environment.processList, id: \.id) { $process in
                            GridRow {
                                VStack(alignment: .leading) {
                                    Text("Process \(process.id + 1)")
                                        .font(.title3)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Arrival Time")
                                            TextField("Whole Number only!", value: $process.arrivalTime, formatter: NumberFormatter())
                                            if errors.contains(.invalidArrivalTime(id: process.id)) {
                                                Label("Must be a whole number", systemImage: "exclamationmark.triangle.fill")
                                                    .foregroundStyle(Color.yellow)
                                                    .font(.caption)
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Turnaround Time")
                                            TextField("Positive Integers only!", value: $process.publicTurnaroundTime, formatter: NumberFormatter())
                                            if errors.contains(.invalidArrivalTime(id: process.id)) {
                                                Label("Must be a positive integer", systemImage: "exclamationmark.triangle.fill")
                                                    .foregroundStyle(Color.yellow)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                }
                            }
                            .gridCellColumns(2)
                            .id("Process-\(process.id)")
                            .padding(8)
                            .background(Color(NSColor.darkGray))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            GridRow {
                HStack {
                    Button("Calculate Schedule") {
                        withAnimation {
                            self.errors = []
                            // Check for any errors prior to running timeline
                            if environment.processCount <= 0 {
                                self.errors.insert(.invalidProcessCount)
                            }
                            
                            if environment.schedulingAlgorithm == .round_robin, environment.timeQuantum <= 0 {
                                self.errors.insert(.invalidTimeQuantum)
                            }
                            
                            for process in environment.processList {
                                if process.arrivalTime < 0 {
                                    self.errors.insert(.invalidArrivalTime(id: process.id))
                                }
                                
                                if process.publicTurnaroundTime <= 0 {
                                    self.errors.insert(.invalidTurnaroundTime(id: process.id))
                                }
                            }
                            
                            // Do not run if errors exist
                            guard self.errors.isEmpty else { return }
                            environment.calculateTimeline()
                        }
                    }
                    
                    Button("Reset App") {
                        withAnimation {
                            environment.resetModel()
                        }
                    }
                }
            }
            .gridCellColumns(2)
            
            if let averageWaitingTime = environment.averageWaitingTime {
                GridRow {
                    Text(String(format: "Average Waiting Time: %.2f", averageWaitingTime))
                }
                .gridCellColumns(2)
            }
        }
        .padding()
    }
    
    enum InputErrors: Hashable {
        case invalidTimeQuantum, invalidProcessCount, invalidTurnaroundTime(id: Int), invalidArrivalTime(id: Int)
    }
}

#Preview {
    ProcessInputView()
        .frame(height: 600)
        .environmentObject(EnvironmentViewModel())
}
