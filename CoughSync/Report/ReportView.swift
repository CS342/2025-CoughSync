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

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

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
                    ShareSheet(activityItems: [pdfURL])
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

    private func exportToPDF(forEmail: Bool = false) {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        let data = pdfRenderer.pdfData { context in
            context.beginPage()

            let hostingController = UIHostingController(rootView: reportCards())
            let targetSize = CGSize(width: 612, height: 792)
            hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
            hostingController.view.backgroundColor = .white

            let rootVC = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first?.rootViewController

            rootVC?.addChild(hostingController)
            hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
            rootVC?.view.addSubview(hostingController.view)

            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("CoughReport.pdf")

        do {
            try data.write(to: tempURL)
            pdfURL = tempURL
            isEmailPresented = forEmail
            isSharing = !forEmail
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CoughReportView(
        presentingAccount: .constant(false)
    )
}
