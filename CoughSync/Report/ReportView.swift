//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import UIKit
import MessageUI

struct CoughReportView: View {
    @State private var isSharing = false
    @State private var isEmailPresented = false
    @State private var pdfURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerView()
                ScrollView {
                    reportCards()
                    shareButton()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitleDisplayMode(.large)
            .padding(.horizontal)
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
                MailView(pdfURL: pdfURL) { result in
                    isEmailPresented = false
                }
            }
        }
    }

    private func headerView() -> some View {
        Text("Cough Report")
            .font(.largeTitle.bold())
    }

    private func reportCards() -> some View {
        VStack(spacing: 15) {
            ReportCard(title: "Daily Report", percentage: 12.5, peakTime: "8:00 PM - 10:00 PM")
            ReportCard(title: "Weekly Report", percentage: -8.3, peakTime: "Wednesday 9:00 AM - 11:00 AM")
            ReportCard(title: "Monthly Report", percentage: 5.2, peakTime: "January 15 at 7:00 PM - 9:00 PM")

            NavigationLink(destination: FrequencyView()) {
                Text("View Cough Frequency Trends →")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
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
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // A4 size in points

        let data = pdfRenderer.pdfData { context in
            context.beginPage()

            let hostingController = UIHostingController(rootView: reportCards())
            let targetSize = CGSize(width: 612, height: 792)
            hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
            hostingController.view.backgroundColor = .white

            let rootVC = UIApplication.shared.windows.first?.rootViewController
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
            if forEmail {
                isEmailPresented = true
            } else {
                isSharing = true
            }
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
        }
    }
}


struct MailView: UIViewControllerRepresentable {
    let pdfURL: URL
    var completion: ((MFMailComposeResult) -> Void)?

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

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            // Capture `parent` safely
            let parent = self.parent

            DispatchQueue.main.async {
                parent.completion?(result)
                controller.dismiss(animated: true)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CoughReportView()
}
