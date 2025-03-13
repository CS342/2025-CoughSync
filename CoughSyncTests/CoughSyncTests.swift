//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import CoughSync
import XCTest


class CoughSyncTests: XCTestCase {
    // Removing the testContactsCount test as it references a non-existent Contacts class
    
    // MARK: - CoughCollection Tests
    
    func testCoughCollectionCount() {
        // Setup
        let coughCollection = CoughCollection()
        let cough1 = Cough(timestamp: Date(), confidence: 0.9)
        let cough2 = Cough(timestamp: Date(), confidence: 0.8)
        
        // Add coughs and verify count
        coughCollection.addCough(cough1)
        coughCollection.addCough(cough2)
        XCTAssertEqual(coughCollection.coughCount, 2, "CoughCollection should have 2 coughs")
    }
    
    func testCoughCollectionResetCoughs() {
        // Setup
        let coughCollection = CoughCollection()
        let cough1 = Cough(timestamp: Date(), confidence: 0.9)
        let cough2 = Cough(timestamp: Date(), confidence: 0.8)
        
        // Add coughs and verify count
        coughCollection.addCough(cough1)
        coughCollection.addCough(cough2)
        XCTAssertEqual(coughCollection.coughCount, 2, "CoughCollection should have 2 coughs")
        
        // Reset coughs and verify count is zero
        coughCollection.resetCoughs()
        XCTAssertEqual(coughCollection.coughCount, 0, "CoughCollection should have 0 coughs after reset")
    }
    
    func testCoughCollectionSetCount() {
        // Setup
        let coughCollection = CoughCollection()
        let initialCount = 5
        
        // Set count and verify
        coughCollection.setCount(initialCount)
        XCTAssertEqual(coughCollection.coughCount, initialCount, "CoughCollection should have \(initialCount) coughs")
        
        // Set a different count and verify
        let newCount = 3
        coughCollection.setCount(newCount)
        XCTAssertEqual(coughCollection.coughCount, newCount, "CoughCollection should have \(newCount) coughs after setCount")
    }
    
    func testCoughsToday() {
        // Setup
        let coughCollection = CoughCollection()
        let todayCough = Cough(timestamp: Date(), confidence: 0.9)
        
        // Yesterday's date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayCough = Cough(timestamp: yesterday, confidence: 0.85)
        
        // Add coughs
        coughCollection.addCough(todayCough)
        coughCollection.addCough(yesterdayCough)
        
        // Verify
        XCTAssertEqual(coughCollection.coughsToday(), 1, "Should count only today's coughs")
        XCTAssertEqual(coughCollection.coughCount, 2, "Total cough count should be 2")
    }
    
    @MainActor
    func testCoughViewModelPropertiesUpdated() {
        // Create a standard
        let standard = CoughSyncStandard()
        
        // Create a view model
        let viewModel = CoughDetectionViewModel(standard: standard)
        
        // Test initial values
        XCTAssertEqual(viewModel.coughCount, 0, "Initial cough count should be 0")
        XCTAssertEqual(viewModel.weeklyAverage, 0, "Initial weekly average should be 0")
        XCTAssertEqual(viewModel.monthlyAverage, 0, "Initial monthly average should be 0")
        
        // Manually update properties
        viewModel.weeklyAverage = 5
        viewModel.monthlyAverage = 10
        
        // Check that properties were updated correctly
        XCTAssertEqual(viewModel.weeklyAverage, 5, "Weekly average should be updated to 5")
        XCTAssertEqual(viewModel.monthlyAverage, 10, "Monthly average should be updated to 10")
    }
    
    // MARK: - CoughEvent Tests
    
    func testCoughEventCreation() {
        let testDate = Date()
        let coughEvent = CoughEvent(date: testDate)
        XCTAssertEqual(coughEvent.date, testDate, "CoughEvent should store the date correctly")
    }
    
    // MARK: - PDF Report Data Tests
    
    func testPDFReportDataModels() {
        // Test ReportCardData
        let reportCardData = PDFReportData.ReportCardData(percentage: 12.5, peakTime: "8:00 PM - 10:00 PM")
        XCTAssertEqual(reportCardData.percentage, 12.5, "Percentage should be stored correctly")
        XCTAssertEqual(reportCardData.peakTime, "8:00 PM - 10:00 PM", "Peak time should be stored correctly")
        
        // Test ChartData
        let dailyCoughs = [10, 15, 20, 25, 30, 20, 15]
        let weeklyCoughs = [50, 60, 70, 55]
        let monthlyCoughs = [200, 250, 300, 280, 220, 240, 260, 270, 290, 300, 280, 250]
        
        let chartData = PDFReportData.ChartData(
            daily: dailyCoughs,
            weekly: weeklyCoughs,
            monthly: monthlyCoughs
        )
        
        XCTAssertEqual(chartData.daily, dailyCoughs, "Daily cough data should be stored correctly")
        XCTAssertEqual(chartData.weekly, weeklyCoughs, "Weekly cough data should be stored correctly")
        XCTAssertEqual(chartData.monthly, monthlyCoughs, "Monthly cough data should be stored correctly")
        
        // Test Report
        let dailyCard = PDFReportData.ReportCardData(percentage: 12.5, peakTime: "8:00 PM - 10:00 PM")
        let weeklyCard = PDFReportData.ReportCardData(percentage: -5.2, peakTime: "9:00 AM - 11:00 AM")
        let monthlyCard = PDFReportData.ReportCardData(percentage: 20.1, peakTime: "7:00 PM - 9:00 PM")
        
        let report = PDFReportData.Report(
            daily: dailyCard,
            weekly: weeklyCard,
            monthly: monthlyCard
        )
        
        XCTAssertEqual(report.daily.percentage, 12.5, "Daily report percentage should be stored correctly")
        XCTAssertEqual(report.weekly.percentage, -5.2, "Weekly report percentage should be stored correctly")
        XCTAssertEqual(report.monthly.percentage, 20.1, "Monthly report percentage should be stored correctly")
    }
    
    // MARK: - PDF Report Generator Tests
    
    func testPDFReportGenerator() {
        // Create test data
        let reportData = PDFReportData.Report(
            daily: PDFReportData.ReportCardData(percentage: 12.5, peakTime: "8:00 PM - 10:00 PM"),
            weekly: PDFReportData.ReportCardData(percentage: -5.2, peakTime: "9:00 AM - 11:00 AM"),
            monthly: PDFReportData.ReportCardData(percentage: 20.1, peakTime: "7:00 PM - 9:00 PM")
        )
        
        let chartData = PDFReportData.ChartData(
            daily: [10, 15, 20, 25, 30, 20, 15],
            weekly: [50, 60, 70, 55],
            monthly: [200, 250, 300, 280, 220, 240, 260, 270, 290, 300, 280, 250]
        )
        
        // Test PDF generation
        let pdfData = PDFReportGenerator.generatePDF(reportData: reportData, chartData: chartData)
        XCTAssertGreaterThan(pdfData.count, 0, "PDF data should not be empty")
        
        // Test saving PDF to a temporary URL
        let url = PDFReportGenerator.savePDF(pdfData)
        XCTAssertNotNil(url, "Should be able to save PDF to a URL")
        
        // Clean up the test file if it exists
        if let url = url {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error cleaning up test PDF file: \(error)")
            }
        }
    }
    
    // MARK: - PDF Drawing Helpers Tests
    
    func testPDFDrawingHelpers() {
        // We need a graphics context to test drawing, so we'll create a minimal PDF context
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let pdfData = renderer.pdfData { context in
            // Test drawing report card
            let yPosition = PDFDrawingHelpers.drawReportCard(
                in: context.pdfContextBounds,
                at: 100,
                title: "Test Report Card",
                percentage: 15.5,
                peakTime: "9:00 PM - 11:00 PM"
            )
            XCTAssertGreaterThan(yPosition, 100, "Drawing should advance Y position")
            
            // Test drawing header
            let headerYPosition = PDFDrawingHelpers.drawHeader(in: context.pdfContextBounds)
            XCTAssertGreaterThan(headerYPosition, 0, "Header drawing should return a positive Y position")
            
            // Test drawing footer
            PDFDrawingHelpers.drawFooter(in: context.pdfContextBounds)
            
            // Test drawing section title
            let sectionYPosition = PDFDrawingHelpers.drawSectionTitle(
                in: context.pdfContextBounds,
                at: 300,
                title: "Test Section"
            )
            XCTAssertGreaterThan(sectionYPosition, 300, "Section title drawing should advance Y position")
            
            // Test drawing trend chart
            let chartYPosition = PDFDrawingHelpers.drawTrendChart(
                in: context.pdfContextBounds,
                at: 400,
                title: "Test Chart",
                data: [10, 20, 30, 40, 50, 40, 30],
                xLabels: ["1", "2", "3", "4", "5", "6", "7"]
            )
            XCTAssertGreaterThan(chartYPosition, 400, "Chart drawing should advance Y position")
        }
        
        // Verify that we got PDF data
        XCTAssertGreaterThan(pdfData.count, 0, "Drawing operations should produce valid PDF data")
    }
    
    // MARK: - CoughReportView PDF Functions Tests
    
    func testReportViewPDFFunctions() {
        // Create test report data
        let reportData = PDFReportData.Report(
            daily: PDFReportData.ReportCardData(percentage: 12.5, peakTime: "8:00 PM - 10:00 PM"),
            weekly: PDFReportData.ReportCardData(percentage: -5.2, peakTime: "9:00 AM - 11:00 AM"),
            monthly: PDFReportData.ReportCardData(percentage: 20.1, peakTime: "7:00 PM - 9:00 PM")
        )
        
        // Create test chart data
        let chartData = PDFReportData.ChartData(
            daily: [10, 15, 20, 25, 30, 20, 15],
            weekly: [50, 60, 70, 55],
            monthly: [200, 250, 300, 280, 220, 240, 260, 270, 290, 300, 280, 250]
        )
        
        // Test PDF generation directly
        let pdfData = PDFReportGenerator.generatePDF(reportData: reportData, chartData: chartData)
        
        // Verify PDF data is generated
        XCTAssertGreaterThan(pdfData.count, 0, "PDF data should not be empty")
        
        // Test that we can save the PDF data
        let url = PDFReportGenerator.savePDF(pdfData)
        XCTAssertNotNil(url, "Should be able to save PDF to a URL")
        
        // Clean up the test file if it exists
        if let url = url {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error cleaning up test PDF file: \(error)")
            }
        }
    }
}
