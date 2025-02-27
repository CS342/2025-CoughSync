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

import SwiftUI
struct CoughModelView: View {
    @State var viewModel = CoughDetectionViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            detectionStatusView()
            Spacer()
            microphoneButton()
        }
        .padding()
    }
    
    private var microphoneImage: some View {
        Image(systemName: viewModel.detectionStarted ? "stop.fill" : "mic.fill")
            .font(.system(size: 50))
            .padding(30)
            .background(viewModel.detectionStarted ? .gray.opacity(0.7) : .blue)
            .foregroundStyle(.white)
            .clipShape(Circle())
            .shadow(color: .gray, radius: 5)
            .contentTransition(.symbolEffect(.replace))
            .accessibilityLabel(viewModel.detectionStarted ? "Stop sound detection" : "Start sound detection")
    }

    @ViewBuilder
    private func detectionStatusView() -> some View {
        if !viewModel.detectionStarted {
            VStack(spacing: 10) {
                ContentUnavailableView(
                    "No Sound Detected",
                    systemImage: "waveform.badge.magnifyingglass",
                    description: Text("Tap the microphone to start detecting")
                )
                Text("Cough Count: \(viewModel.coughCount)")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        } else if let predictedSound = viewModel.identifiedSound {
            VStack(spacing: 10) {
                Text(predictedSound.0)
                    .font(.system(size: 26))
                Text("Cough Count: \(viewModel.coughCount)")
                Text("Coughs Today: \(viewModel.coughCollection.coughsToday())")
                Text("Cough Difference: \(viewModel.coughCollection.coughDiffDay())")
            }
            .multilineTextAlignment(.center)
            .padding()
            .foregroundStyle(.secondary)
            .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
        } else {
            ProgressView("Identifying Cough...")
        }
    }
    
    private func microphoneButton() -> some View {
        Button(action: {
            toggleListening()
        }, label: {
            microphoneImage
        })
    }
    
    private func toggleListening() {
        withAnimation {
            viewModel.detectionStarted.toggle()
        }
        if viewModel.detectionStarted {
            viewModel.startListening()
        } else {
            viewModel.stopListening()
        }
    }
}
