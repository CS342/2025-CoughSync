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

/// A card that displays a summary of a report.
struct ReportCard: View {
    let title: String
    let percentage: Double
    let peakTime: String

    private var percentageText: String {
        percentage >= 0 ? "\(String(format: "%.1f", percentage))%" : "\(String(format: "%.1f", percentage * -1))%"
    }

    private var percentageSymbol: String {
        percentage >= 0 ? "arrow.up" : "arrow.down"
    }
    
    private var percentageColor: Color {
        percentage >= 0 ? Color.orange : Color.blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.bold())
                .lineLimit(1)
                .frame(height: 10)
            HStack {
                Text("Change in Coughs: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 150, alignment: .leading)
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: percentageSymbol)
                        .foregroundColor(percentageColor)
                        .accessibilityLabel(percentageSymbol)
                    Text(percentageText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(percentageColor)
                        .lineLimit(1)
                }
            }
            .frame(height: 30)
            
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.gray)
                    .accessibilityLabel("Clock icon")
                Text("Peak Time: \(peakTime)")
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(height: 30)
        }
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
        )
        .frame(height: 150)
        .frame(width: 350)
        .padding(.horizontal)
    }
}

#Preview {
    ReportCard(title: "Daily Report", percentage: 12.5, peakTime: "Hello hello hello I am cool 8:00 PM - 10:00 PM")
}
