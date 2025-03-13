//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
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
    struct Report {
        let daily: ReportCardData
        let weekly: ReportCardData
        let monthly: ReportCardData
    }
    
    /// Data for chart components
    struct ChartData {
        let daily: [Int]
        let weekly: [Int]
        let monthly: [Int]
    }
}

// MARK: - PDF Generator

/// Generates PDF reports for cough data
enum PDFReportGenerator {
    /// Generates the PDF document
    static func generatePDF(reportData: PDFReportData.Report, chartData: PDFReportData.ChartData) -> Data {
        // Create PDF document with standard page size
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard US Letter
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        return pdfRenderer.pdfData { context in
            // First page - Report summary
            context.beginPage()
            
            // Draw header
            let yPosition = PDFDrawingHelpers.drawHeader(in: pageRect)
            
            // Draw report cards
            let afterCardsPosition = drawReportCards(
                in: context.pdfContextBounds,
                startYPosition: yPosition,
                reportData: reportData
            )
            
            // Draw chart section title
            let chartsSectionY = PDFDrawingHelpers.drawSectionTitle(
                in: pageRect,
                at: afterCardsPosition + 40,
                title: "Cough Trends"
            )
            
            // Draw trend charts
            drawTrendCharts(
                in: context,
                pageRect: pageRect,
                startYPosition: chartsSectionY,
                chartData: chartData
            )
            
            // Add footer
            PDFDrawingHelpers.drawFooter(in: pageRect)
        }
    }
    
    /// Draws the report cards in the PDF
    private static func drawReportCards(
        in rect: CGRect,
        startYPosition: CGFloat,
        reportData: PDFReportData.Report
    ) -> CGFloat {
        var yPosition = startYPosition
        
        yPosition = PDFDrawingHelpers.drawReportCard(
            in: rect,
            at: yPosition,
            title: "Daily Report",
            percentage: reportData.daily.percentage,
            peakTime: reportData.daily.peakTime
        )
        
        yPosition = PDFDrawingHelpers.drawReportCard(
            in: rect,
            at: yPosition + 20,
            title: "Weekly Report",
            percentage: reportData.weekly.percentage,
            peakTime: reportData.weekly.peakTime
        )
        
        yPosition = PDFDrawingHelpers.drawReportCard(
            in: rect,
            at: yPosition + 20,
            title: "Monthly Report",
            percentage: reportData.monthly.percentage,
            peakTime: reportData.monthly.peakTime
        )
        
        return yPosition // Return Y position after all cards
    }
    
    /// Draws trend charts in the PDF
    private static func drawTrendCharts(
        in context: UIGraphicsPDFRendererContext,
        pageRect: CGRect,
        startYPosition: CGFloat,
        chartData: PDFReportData.ChartData
    ) {
        var yPosition = startYPosition
        
        // Draw Daily Trend Chart
        yPosition = PDFDrawingHelpers.drawTrendChart(
            in: context.pdfContextBounds,
            at: yPosition,
            title: "Daily Coughs (Past Week)",
            data: chartData.daily,
            xLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        )
        
        // Check if we need a new page for the next chart
        if yPosition > pageRect.height - 200 {
            context.beginPage()
            yPosition = 50
        }
        
        // Draw Weekly Trend Chart
        yPosition = PDFDrawingHelpers.drawTrendChart(
            in: context.pdfContextBounds,
            at: yPosition + 30,
            title: "Weekly Coughs (Past Month)",
            data: chartData.weekly,
            xLabels: ["Week 1", "Week 2", "Week 3", "Week 4"]
        )
        
        // Check if we need a new page for the next chart
        if yPosition > pageRect.height - 200 {
            context.beginPage()
            yPosition = 50
        }
        
        // Draw Monthly Trend Chart
        PDFDrawingHelpers.drawTrendChart(
            in: context.pdfContextBounds,
            at: yPosition + 30,
            title: "Monthly Coughs (Past Year)",
            data: chartData.monthly,
            xLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        )
    }
    
    /// Saves the PDF data to a temporary file
    static func savePDF(_ data: Data) -> URL? {
        // Generate a unique filename to avoid caching issues
        let timestamp = Int(Date().timeIntervalSince1970)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("CoughReport-\(timestamp).pdf")

        do {
            try data.write(to: tempURL)
            print("PDF successfully generated at: \(tempURL)")
            return tempURL
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
