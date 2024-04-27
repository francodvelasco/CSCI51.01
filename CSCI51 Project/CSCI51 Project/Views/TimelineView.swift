//
//  TimelineView.swift
//  CSCI51 Project
//
//  Created by Franco Velasco on 4/11/24.
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var environment: EnvironmentViewModel
    
    var body: some View {
        if let _ = environment.averageWaitingTime {
            ScrollView(.vertical) {
                Grid(verticalSpacing: 1) {
                    GridRow {
                        Text("Time")
                        
                        ForEach(environment.processList, id: \.id) { process in
                            Text("Process \(process.id + 1)")
                        }
                    }
                    
                    ForEach(0..<environment.lastRuntime, id: \.self) { time in
                        GridRow {
                            Text("\(time)")
                                .gridCellAnchor(.topTrailing)
                            
                            ForEach(environment.processList, id: \.id) { process in
                                Rectangle()
                                    .fill(environment.processRunningAtTime[time] == process.id ? process.color : .clear)
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                }
            }
            .padding(.trailing)
        } else {
            VStack {
                Spacer()
                Text("No Timeline Generated")
                Spacer()
            }
        }
    }
}

public extension Color {
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}

#Preview {
    TimelineView()
}
