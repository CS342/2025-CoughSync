//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import MessageUI
import SpeziAccount
import SwiftUI
import UIKit

// MARK: - Mail View Coordinator

class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    var parent: MailView

    init(_ parent: MailView) {
        self.parent = parent
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        // Capture self weakly to avoid reference cycles
        let parent = self.parent
        
        // Use Task instead of DispatchQueue
        Task { @MainActor in
            parent.completion?(result)
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Mail View

struct MailView: UIViewControllerRepresentable {
    var completion: ((MFMailComposeResult) -> Void)?
    let pdfURL: URL
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setSubject("Cough Report")
        mailComposeVC.setMessageBody("Attached is your Cough Report.", isHTML: false)

        if let pdfData = try? Data(contentsOf: pdfURL) {
            mailComposeVC.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: "CoughReport.pdf")
        }

        return mailComposeVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

// MARK: - Share Sheet

/// A view that wraps UIActivityViewController for sharing items
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        if let pdfURL = items.first as? URL {
            return createShareViewController(with: pdfURL)
        } else if let pdfData = items.first as? Data {
            return handlePDFData(pdfData)
        }
        
        // Fallback for any other content
        return UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    // MARK: - Private Helpers
    
    /// Creates a share view controller for a PDF URL
    private func createShareViewController(with url: URL) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
    }
    
    /// Handles PDF data by writing to temp file and sharing
    private func handlePDFData(_ data: Data) -> UIActivityViewController {
        let timestamp = Int(Date().timeIntervalSince1970)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("CoughReport-\(timestamp).pdf")
        
        do {
            try data.write(to: tempURL)
            print("PDF data written to: \(tempURL)")
            return createShareViewController(with: tempURL)
        } catch {
            print("Error writing PDF: \(error)")
            // Fallback in case of error
            return UIActivityViewController(
                activityItems: [],
                applicationActivities: nil
            )
        }
    }
}

// MARK: - Main View

struct CoughReportView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(CoughSyncStandard.self) private var standard
    @StateObject private var coughTracker = CoughTracker()
    @Binding var presentingAccount: Bool
    @State private var isLoadingData = true
    @State private var isSharing = false
    @State private var isEmailPresented = false
    @State private var pdfURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                ScrollView {
                    reportCards()
                    shareButton()
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                setupAndLoad()
            }
            .navigationTitle("Report")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .sheet(isPresented: Binding(
                get: { pdfURL != nil && isSharing },
                set: { _ in isSharing = false }
            )) {
                if let pdfURL = pdfURL {
                    ShareSheet(items: [pdfURL])
                }
            }
            .sheet(isPresented: $isEmailPresented) {
                if let pdfURL = pdfURL {
                    MailView(completion: { _ in
                        isEmailPresented = false
                    }, pdfURL: pdfURL)
                }
            }
            .refreshable {
                await coughTracker.loadCoughEvents()
            }
        }
    }

    private func setupAndLoad() {
        coughTracker.standard = standard
        isLoadingData = true

        Task {
            await coughTracker.loadCoughEvents()
            isLoadingData = false
        }
    }

    private func reportCards() -> some View {
        let dailyData = coughTracker.generateDailyReportData()
        let weeklyData = coughTracker.generateWeeklyReportData()
        let monthlyData = coughTracker.generateMonthlyReportData()

        return Group {
            if !isLoadingData {
                VStack(spacing: 10) {
                    ReportCard(title: "Daily Report", percentage: dailyData.percentage, peakTime: dailyData.peakTime)
                    ReportCard(title: "Weekly Report", percentage: weeklyData.percentage, peakTime: weeklyData.peakTime)
                    ReportCard(title: "Monthly Report", percentage: monthlyData.percentage, peakTime: monthlyData.peakTime)

                    NavigationLink(destination: CoughTrackerView()) {
                        Text("View Cough Frequency Trends →")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                ProgressView("Loading cough data...")
                    .padding()
            }
        }
    }

    private func shareButton() -> some View {
        Menu {
            Button(action: {
                exportToPDF()
            }) {
                Label("Save as", systemImage: "square.and.arrow.up")
            }

            Button(action: {
                exportToPDF(forEmail: true)
            }) {
                Label("Email Report", systemImage: "envelope")
            }
            
            Button(action: {
                exportToPDF(directShare: true)
            }) {
                Label("Direct Share PDF", systemImage: "doc.text")
            }
        } label: {
            Label("Share Report", systemImage: "square.and.arrow.up")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }

    private func exportToPDF(forEmail: Bool = false, directShare: Bool = false) {
        // Clear any cached PDF
        self.pdfURL = nil
        
        // Get data needed for PDF generation
        let reportData = getReportData()
        let chartData = getChartData()
        
        // Generate PDF document using the helper
        let data = PDFReportGenerator.generatePDF(reportData: reportData, chartData: chartData)
        
        // Save PDF to temp file and share
        if let url = PDFReportGenerator.savePDF(data) {
            pdfURL = url
            
            // Present sharing options
            if directShare {
                self.isSharing = true
            } else {
                self.isEmailPresented = forEmail
                self.isSharing = !forEmail
            }
        }
    }
    
    /// Retrieves all report data needed for the PDF
    private func getReportData() -> PDFReportData.Report {
        let dailyData = coughTracker.generateDailyReportData()
        let weeklyData = coughTracker.generateWeeklyReportData()
        let monthlyData = coughTracker.generateMonthlyReportData()
        
        return PDFReportData.Report(
            daily: PDFReportData.ReportCardData(percentage: dailyData.percentage, peakTime: dailyData.peakTime),
            weekly: PDFReportData.ReportCardData(percentage: weeklyData.percentage, peakTime: weeklyData.peakTime),
            monthly: PDFReportData.ReportCardData(percentage: monthlyData.percentage, peakTime: monthlyData.peakTime)
        )
    }
    
    /// Retrieves all chart data needed for the PDF
    private func getChartData() -> PDFReportData.ChartData {
        PDFReportData.ChartData(
            daily: CoughReportData.getDailyCoughs(),
            weekly: CoughReportData.getWeeklyCoughs(),
            monthly: CoughReportData.getMonthlyCoughs()
        )
    }
}

#Preview {
    CoughReportView(
        presentingAccount: .constant(false)
    )
}