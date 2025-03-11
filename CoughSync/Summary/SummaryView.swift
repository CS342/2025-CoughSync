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
import FirebaseAuth
import FirebaseFirestore
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
    @State private var isLoadingData: Bool = true
    @State private var isRecording: Bool = true
    @State private var timer: Timer?
    
    // MARK: - Body
    var body: some View {
        GeometryReader {geometry in
            NavigationStack {
                viewContent(geometry: geometry)
                .navigationTitle("Summary")
                .toolbar {
                    if account != nil {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .onAppear {
                    // Initialize viewModel here when environment is available
                    loadCoughData()
                }
                .onDisappear {
                    stopData()
                }
                .onChange(of: viewModel?.detectionStarted) { _, newCount in
                    if newCount == true {
                        isRecording = true
                        reloadData()
                    } else {
                        isRecording = false
                        stopData()
                    }
                }
                .onChange(of: viewModel?.coughCount) { oldValue, _ in
                    previousCoughCount = oldValue ?? 0
                }

                .onAppear {
                    if isRecording == true {
                        reloadData()
                    }
                }
                .refreshable {
                    loadCoughData()
                }
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
    private func viewContent(geometry: GeometryProxy) -> some View {
        ZStack {
            if let viewModel = viewModel, !isLoadingData {
                VStack(spacing: geometry.size.height * 0.02) {
                    coughSummaryCard(geometry: geometry)
                    coughStats(geometry: geometry)
                    Divider()
                    CoughModelView(viewModel: $viewModel)
                }
                .padding()
                // reducing effect of flashing screen when loading data
                .opacity(isLoadingData ? 0.5 : 1)
            }
            // Using ZStack to avoid flashing during reloads- progress bar effect
            if isLoadingData {
            // Show a loading indicator or placeholder
            ProgressView("Loading cough data...")
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            }
        }
    }
    
    @ViewBuilder
    private func coughSummaryCard(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("\(viewModel?.coughCount ?? 0) ")
                    .font(.system(size: geometry.size.width * 0.12, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                +
                Text("coughs")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            HStack {
                Spacer()
                statusCircle(geometry: geometry)
            }
        }
        .padding()
        .frame(maxWidth: geometry.size.width * 0.85)
        .background(.thinMaterial) // Subtle differentiation, more clear / transparent
        .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.04))
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func coughStats(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.05) {
            statCard(
                title: "This Week",
                value: "\(viewModel?.weeklyAverage ?? 0)",
                geometry: geometry,
                fontColor: .purple
            )
            statCard(
                title: "This Month",
                value: "\(viewModel?.monthlyAverage ?? 0)",
                geometry: geometry,
                fontColor: .mint
            )
        }
        .frame(maxWidth: geometry.size.width * 0.85)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func statCard(title: String, value: String, geometry: GeometryProxy, fontColor: Color = .blue) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(value) ")
                .font(.system(size: geometry.size.width * 0.06))
                .bold()
                .foregroundColor(fontColor)
            +
            Text("coughs/d")
                .font(.footnote)
                .foregroundColor(fontColor)
        }
        .frame(maxWidth: geometry.size.width * 0.40)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(geometry.size.width * 0.04)
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    private func statusCircle(geometry: GeometryProxy) -> some View {
        let change = viewModel?.coughCount ?? 0 - previousCoughCount
        let color: Color = change > 0 ? .orange : (change < 0 ? .green : .blue)
        let trendSymbol = change > 0 ? "↑" : (change < 0 ? "↓" : "–")
        
        Circle()
            .fill(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .top, endPoint: .bottom))
            .frame(width: geometry.size.width * 0.12)
            .overlay(
                Text(trendSymbol)
                    .font(.title2)
                    .foregroundColor(.white)
            )
            .shadow(radius: 5)
            .accessibilityLabel(Text(change > 0 ? "Increase in coughs" : "Decrease in coughs"))
    }
    
    private func loadCoughData() {
        isLoadingData = true
        previousCoughCount = viewModel?.coughCount ?? 0
        viewModel?.fetchCoughData { success in
            isLoadingData = false
            if !success {
                // Handle error case if needed
                print("Failed to load cough data")
            }
        }
    }
    
    private func reloadData() {
        stopData()
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            DispatchQueue.main.async {
                loadCoughData()
            }
        }
    }
    
    private func stopData() {
        timer?.invalidate()
        timer = nil
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
