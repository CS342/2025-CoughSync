//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//  CoughModelView.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Spezi
import SwiftUI

/// A view that displays the cough detection model and user interface.
///
/// This view provides a user interface for starting and stopping cough detection
/// and displays the current status of the detection process.
struct CoughModelView: View {
    @Binding var viewModel: CoughDetectionViewModel?
    
    var body: some View {
        VStack {
            Spacer()
            detectionStatusView()
            Spacer()
            microphoneButton()
        }
    }

    @ViewBuilder
    private func detectionStatusView() -> some View {
        if viewModel?.detectionStarted == false {
            VStack(spacing: 10) {
                ContentUnavailableView(
                    "Ready for bed?",
                    systemImage: "bed.double.fill",
                    description: Text("Tap below to begin detecting nighttime coughs.")
                )
            }
        } else if (viewModel?.identifiedSound) != nil {
            VStack(spacing: 10) {
                ContentUnavailableView(
                    "Tracking in Progress",
                    systemImage: "lines.measurement.horizontal",
                    description: Text("""
                        Tap below to stop detecting coughs.
                        Tracking for \(elapsedTimeString(since: viewModel?.detectionStatedDate ?? Date()))
                    """)
                )
            }
        } else {
            VStack {
                ProgressView("Starting...")
                    .progressViewStyle(.circular)
                    .padding(.top, 50)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
        }
    }
    
    private func microphoneButton() -> some View {
        Button(action: {
            toggleListening()
        }) {
            Text(viewModel?.detectionStarted == true ? "Stop tracking" : "Start tracking")
                .font(.headline)
                .padding()
                .frame(minWidth: 200)
                .background(viewModel?.detectionStarted == true ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func elapsedTimeString(since startDate: Date) -> String {
        let elapsed = Int(Date().timeIntervalSince(startDate))
        
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func toggleListening() {
        withAnimation {
            viewModel?.detectionStarted.toggle()
        }
        if viewModel?.detectionStarted == true {
            viewModel?.startListening()
            viewModel?.detectionStatedDate = Date()
        } else {
            viewModel?.stopListening()
        }
    }
}
