//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

struct CoughModelView: View {
    @Binding var viewModel: CoughDetectionViewModel?
    @State private var showChargingReminder = false
    
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
        .alert("Keep Your Phone Plugged In", isPresented: $showChargingReminder) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("For accurate cough tracking throughout the night, please keep your phone plugged in and charging close to your bed")
        }
    }

    @ViewBuilder
    private func detectionStatusView() -> some View {
        ZStack {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
            }
        }
        .frame(height: 193)
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
                .clipShape(Circle())
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
            showChargingReminder = true // Show the alert when tracking starts
        } else {
            viewModel?.stopListening()
        }
    }
}
