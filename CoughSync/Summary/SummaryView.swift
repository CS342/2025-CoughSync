//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//
//  SummaryView.swift
//  CoughSync
//
//  Created by Miguel Fuentes on 2/24/25.
//

import Charts
import SpeziAccount
import SpeziScheduler
import SpeziSchedulerUI
import SpeziViews
import SwiftUI

/// `SummaryView` is a view that displays a summary of cough detection data.
///
/// This view provides a summary of cough detection data, including the number of coughs detected
/// today, this week, and this month. It also displays a visual representation of the cough count
/// and a trend indicator.
struct SummaryView: View {
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    @Binding var viewModel: CoughDetectionViewModel?
    @State private var previousCoughCount: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    coughSummaryCard()
                    coughStats()
                    Divider()
                    CoughModelView(viewModel: $viewModel)
                }
                .padding()
            }
            .navigationTitle("Summary")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .onAppear {
                previousCoughCount = viewModel?.coughCount ?? 0
            }
            .onChange(of: viewModel?.coughCount) { oldValue, _ in
                previousCoughCount = oldValue ?? 0
            }
        }
    }
    
    init(
        presentingAccount: Binding<Bool>,
        viewModel: Binding<CoughDetectionViewModel?>
    ) {
        self._presentingAccount = presentingAccount
        self._viewModel = viewModel
    }
    
    @ViewBuilder
    private func coughSummaryCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("\(viewModel?.coughCount ?? 0) ")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                +
                Text("coughs")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            HStack {
                Spacer()
                statusCircle()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial) // Subtle differentiation, more clear / transparent
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    private func coughStats() -> some View {
        HStack(spacing: 16) {
            statCard(title: "This Week", value: "20", fontColor: .purple)
            statCard(title: "This Month", value: "15", fontColor: .mint)
        }
    }
    
    @ViewBuilder
    private func statCard(title: String, value: String, fontColor: Color = .blue) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(value) ")
                .font(.title2)
                .bold()
                .foregroundColor(fontColor)
            +
            Text("coughs/d")
                .font(.footnote)
                .foregroundColor(fontColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    private func statusCircle() -> some View {
        let change = viewModel?.coughCount ?? 0 - previousCoughCount
        let color: Color = change > 0 ? .red : (change < 0 ? .green : .blue)
        let trendSymbol = change > 0 ? "↑" : (change < 0 ? "↓" : "–")
        
        Circle()
            .fill(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .top, endPoint: .bottom))
            .frame(width: 50, height: 50)
            .overlay(
                Text(trendSymbol)
                    .font(.title2)
                    .foregroundColor(.white)
            )
            .shadow(radius: 5)
            .accessibilityLabel(Text(change > 0 ? "Increase in coughs" : "Decrease in coughs"))
    }
}

#Preview {
    SummaryView(
        presentingAccount: .constant(false),
        viewModel: .constant(CoughDetectionViewModel(
            standard: CoughSyncStandard()
        ))
    )
}
