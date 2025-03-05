//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//  ReportCard.swift
//  CoughSync
//

import SwiftUI

struct ReportCard: View {
    let title: String
    let percentage: Double
    let peakTime: String

    private var percentageText: String {
        percentage >= 0 ? "+\(String(format: "%.1f", percentage))%" : "\(String(format: "%.1f", percentage))%"
    }

    private var percentageColor: Color {
        percentage >= 0 ? .orange : .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.primary)

            HStack {
                Text("Coughs Change: ")
                    .foregroundColor(.primary)
                Text(percentageText)
                    .fontWeight(.bold)
                    .foregroundColor(percentageColor)
            }

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.gray)
                    .accessibilityLabel("Clock icon")
                Text("Peak Time: \(peakTime)")
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))

        .padding(.horizontal)
    }
}

#Preview {
    ReportCard(title: "Daily Report", percentage: 12.5, peakTime: "8:00 PM - 10:00 PM")
}
