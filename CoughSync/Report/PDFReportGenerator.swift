//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
<<<<<<< HEAD

import Foundation
import PDFKit
import UIKit

// MARK: - Report Data Models
/// Namespace for PDF report data models
enum PDFReportData {
    /// Represents the complete report data
=======
import SwiftUI
import UIKit

// MARK: - PDF Data Models

/// PDF report components data structure
enum PDFReportData {
    struct ReportCardData {
        let percentage: Double
        let peakTime: String
    }
    
    /// Data for a full report
>>>>>>> 1a0f434d7073639d9f79084431ae2d167bf1e6f3
    struct Report {
        let daily: ReportCardData
        let weekly: ReportCardData
        let monthly: ReportCardData
    }
    
    /// Represents a report card's data
    struct ReportCardData {
        let percentage: Double
        let peakTime: String
    }
    
    /// Contains chart data for the report
    struct ChartData {
        let daily: [Int]
        let weekly: [Int]
        let monthly: [Int]
    }
}

// MARK: - PDF Generator
<<<<<<< HEAD
/// Generator for PDF reports
enum PDFReportGenerator {
    // MARK: - Public API
    
    /// Generates a PDF report from the provided data
=======

/// Generates PDF reports for cough data
enum PDFReportGenerator {
    /// Generates the PDF document
>>>>>>> 1a0f434d7073639d9f79084431ae2d167bf1e6f3
    static func generatePDF(reportData: PDFReportData.Report, chartData: PDFReportData.ChartData) -> Data {
        // Create PDF document with standard US Letter size (8.5 x 11 inches)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        return renderer.pdfData { context in
            // Generate first page with summary report cards
            generateFirstPage(context: context, reportData: reportData, chartData: chartData)
            
            // Generate second page with additional charts
            generateSecondPage(context: context, chartData: chartData)
        }
    }
    
    /// Saves PDF data to a temporary file and returns the URL
    static func savePDF(_ pdfData: Data) -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("CoughReport-\(timestamp).pdf")
        
        do {
            try pdfData.write(to: tempURL)
            print("PDF saved to: \(tempURL)")
            return tempURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    /// Generates the first page of the PDF with report cards and daily chart
    private static func generateFirstPage(
        context: UIGraphicsPDFRendererContext,
        reportData: PDFReportData.Report,
        chartData: PDFReportData.ChartData
    ) {
        context.beginPage()
        let currentPage = context.pdfContextBounds
        
        // Draw header section
        var yPosition = PDFDrawingHelpers.drawHeader(in: currentPage)
        
        // Draw report cards section
        yPosition = drawReportCards(in: currentPage, at: yPosition, reportData: reportData)
        
        // Draw trend charts section title
        yPosition = PDFDrawingHelpers.drawSectionTitle(
            in: currentPage,
            at: yPosition + 40,
            title: "Cough Trends Analysis"
        )
        
        // Draw daily trend chart
        PDFDrawingHelpers.drawTrendChart(
            in: currentPage,
            at: yPosition,
            title: "Daily Coughs (Past Week)",
            data: chartData.daily,
            xLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        )
        
        // Add footer
        PDFDrawingHelpers.drawFooter(in: currentPage)
    }
    
    /// Generates the second page of the PDF with weekly and monthly charts
    private static func generateSecondPage(
        context: UIGraphicsPDFRendererContext,
        chartData: PDFReportData.ChartData
    ) {
        context.beginPage()
        let currentPage = context.pdfContextBounds
        
        // Initial Y position on the new page
        var yPosition: CGFloat = 50
        
        // Draw weekly trend chart
        yPosition = PDFDrawingHelpers.drawTrendChart(
            in: currentPage,
            at: yPosition,
            title: "Weekly Coughs (Past Month)",
            data: chartData.weekly,
            xLabels: ["Week 1", "Week 2", "Week 3", "Week 4"]
        )
        
        // Draw monthly trend chart
        PDFDrawingHelpers.drawTrendChart(
            in: currentPage,
            at: yPosition + 20,
            title: "Monthly Coughs (Past Year)",
            data: chartData.monthly,
            xLabels: getMonthLabels()
        )
        
        // Add footer
        PDFDrawingHelpers.drawFooter(in: currentPage)
    }
    
    /// Helper to draw all three report cards
    private static func drawReportCards(
        in rect: CGRect,
        at startY: CGFloat,
        reportData: PDFReportData.Report
    ) -> CGFloat {
        var yPosition = startY + 20
        
        // Draw daily report card
        yPosition = PDFDrawingHelpers.drawReportCard(
            in: rect,
            at: yPosition,
            title: "Daily Report",
            percentage: reportData.daily.percentage,
            peakTime: reportData.daily.peakTime
        )
        
        // Draw weekly report card
        yPosition = PDFDrawingHelpers.drawReportCard(
            in: rect,
            at: yPosition + 20,
            title: "Weekly Report",
            percentage: reportData.weekly.percentage,
            peakTime: reportData.weekly.peakTime
        )
        
        // Draw monthly report card
        yPosition = PDFDrawingHelpers.drawReportCard(
            in: rect,
            at: yPosition + 20,
            title: "Monthly Report",
            percentage: reportData.monthly.percentage,
            peakTime: reportData.monthly.peakTime
        )
        
        return yPosition
    }
    
    /// Returns month labels for x-axis of monthly chart
    private static func getMonthLabels() -> [String] {
        [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ]
    }
}
