//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Spezi

struct CoughTrackerView: View {
    @Environment(CoughSyncStandard.self) private var standard
    @StateObject private var coughTracker = CoughTracker()
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            .navigationTitle("Cough Tracker")
            .onAppear {
                setupAndLoad()
            }
            .refreshable {
                await coughTracker.loadCoughEvents()
            }
        }
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        ProgressView("Loading cough data...")
    }
    
    private var contentView: some View {
        List {
            Section {
                hourlyChartView
            }
            
            Section {
                weeklyChartView
            }
            
            if let errorMessage = coughTracker.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var hourlyChartView: some View {
        CoughChartView(
            coughEvents: coughTracker.coughEvents,
            xName: "Time",
            yName: "Cough Count",
            title: "Hourly Coughs (Today)",
            isWeekly: false
        )
    }
    
    private var weeklyChartView: some View {
        CoughChartView(
            coughEvents: coughTracker.coughEvents,
            xName: "Day",
            yName: "Cough Count",
            title: "Daily Coughs (Past 7 Days)",
            isWeekly: true
        )
    }
    
    // MARK: - Helper Methods
    
    private func setupAndLoad() {
        coughTracker.standard = standard
        isLoading = true
        
        Task {
            await coughTracker.loadCoughEvents()
            isLoading = false
        }
    }
}

#Preview {
    CoughTrackerView()
}
