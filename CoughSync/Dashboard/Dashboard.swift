//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//
//  Dashboard.swift
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


struct Dashboard: View {
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    
    @State private var viewModel = CoughDetectionViewModel()
    @State private var previousCoughCount: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    coughSummaryCard()
                    coughStats()
                    Divider()
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
                previousCoughCount = viewModel.coughCount
            }
            .onChange(of: viewModel.coughCount) { oldValue, newValue in
                previousCoughCount = oldValue
            }
        }
    }
    
    @ViewBuilder
    private func coughSummaryCard() -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(viewModel.coughCount) ")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                    +
                    Text("coughs")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                Spacer()
                statusCircle()
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground)) // Subtle differentiation
        .cornerRadius(12)
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
        let change = viewModel.coughCount - previousCoughCount
        let color: Color = change > 0 ? .red : (change < 0 ? .green : .blue)
        let trendSymbol = change > 0 ? "↑" : (change < 0 ? "↓" : "–")
        
        Circle()
            .fill(color)
            .frame(width: 50, height: 50)
            .overlay(
                Text(trendSymbol)
                    .font(.title2)
                    .foregroundColor(.white)
            )
            .shadow(radius: 5)
    }
}

#Preview {
    Dashboard(presentingAccount: .constant(false))
}
