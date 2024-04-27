//
//  MainView.swift
//  CSCI51 Project
//
//  Created by Franco Velasco on 4/11/24.
//

import SwiftUI

@available(macOS 14, *)
struct MainView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ProcessInputView()
            
            TimelineView()
                .frame(minWidth: 450, idealWidth: 450, maxWidth: 450, minHeight: .zero, maxHeight: .infinity, alignment: .top)
                .padding([.vertical, .trailing], 16)
        }
        .frame(width: 800, height: 600)
    }
}

#Preview {
    MainView()
        .frame(width: 800, height: 600)
        .environmentObject(EnvironmentViewModel())
}
