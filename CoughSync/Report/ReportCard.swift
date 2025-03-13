//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ReportCard: View {
    let title: String
    let percentage: Double
    let peakTime: String
    
    @Environment(\.colorScheme) private var colorScheme

    private var percentageText: String {
        percentage >= 0 ? "\(String(format: "%.1f", percentage))%" : "\(String(format: "%.1f", percentage * -1))%"
    }

    private var percentageSymbol: String {
        percentage > 0 ? "arrow.up" : percentage < 0 ? "arrow.down" : "minus"
    }
    
    private var percentageColor: Color {
        percentage > 0 ? Color.orange : Color.blue
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
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(UIColor.separator), lineWidth: 3)
        )
        .frame(height: 150)
        .frame(width: 350)
        .padding(.horizontal)
    }
}

#Preview {
    Group {
        ReportCard(title: "Daily Report", percentage: 12.5, peakTime: "8:00 PM - 10:00 PM")
            .preferredColorScheme(.light)
        
        ReportCard(title: "Weekly Report", percentage: -5.2, peakTime: "Monday 2:00 PM - 4:00 PM")
            .preferredColorScheme(.dark)
    }
}
