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
            detectionStatusView()
                .animation(.easeInOut(duration: 0.3), value: viewModel?.detectionStarted)
            Spacer()
            microphoneButton()
                .animation(.easeInOut(duration: 0.3), value: viewModel?.detectionStarted)
                .padding(.bottom, 50)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func detectionStatusView() -> some View {
        ZStack { // this keeps elements in stack without shifting layout
            if viewModel?.detectionStarted == false {
                ContentUnavailableView(
                    "Ready for bed?",
                    systemImage: "bed.double.fill",
                    description: Text("Tap below to begin detecting nighttime coughs.")
                )
            } else if (viewModel?.identifiedSound) != nil {
                ContentUnavailableView(
                    "Tracking in Progress",
                    systemImage: "waveform.path.ecg",
                    description: Text("""
                    Tap below to stop detecting coughs.
                    Tracking for \(elapsedTimeString(since: viewModel?.detectionStatedDate ?? Date()))
                """)
                )
            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(0.8)
                    Text("Starting...")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // keep everything centred
                .background(Color(.systemBackground).opacity(0.8))
            }
        }
        .frame(height: 193) // keeps button fixed
    }
    
    private func microphoneButton() -> some View {
        Button(action: {
            toggleListening()
        }) {
            Image(systemName: viewModel?.detectionStarted == true ? "stop.fill" : "mic.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(viewModel?.detectionStarted == true ? Color.red.gradient : Color.blue.gradient)
                .clipShape(Circle()) // circle might be more visually appealing?
                .shadow(radius: 5)
                .padding(.top, 10)
        }
        .accessibilityLabel(viewModel?.detectionStarted == true ? "Stop tracking" : "Start tracking")
    }
    
    private func elapsedTimeString(since startDate: Date) -> String {
        let elapsed = Int(Date().timeIntervalSince(startDate))
        
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func toggleListening() {
        viewModel?.detectionStarted.toggle()
        if viewModel?.detectionStarted == true {
            viewModel?.startListening()
            viewModel?.detectionStatedDate = Date()
        } else {
            viewModel?.stopListening()
        }
    }
}
