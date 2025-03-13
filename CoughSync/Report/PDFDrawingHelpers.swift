//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import UIKit
import SwiftUI

/// Contains PDF drawing functionality for CoughSync reports
struct PDFDrawingHelpers {
    /// Draws a report card in the PDF document
    static func drawReportCard(
        in rect: CGRect,
        at yPosition: CGFloat,
        title: String,
        percentage: Double,
        peakTime: String
    ) -> CGFloat {
        let pageWidth = rect.width
        let cardWidth = pageWidth - 100
        let cardHeight: CGFloat = 100
        
        // Draw rounded rectangle background
        let cardRect = CGRect(x: 50, y: yPosition, width: cardWidth, height: cardHeight)
        let path = UIBezierPath(roundedRect: cardRect, cornerRadius: 10)
        UIColor.systemGray6.setFill()
        path.fill()
        
        // Draw border
        UIColor.systemGray4.setStroke()
        path.lineWidth = 1
        path.stroke()
        
        // Draw title
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleRect = CGRect(x: 65, y: yPosition + 15, width: cardWidth - 30, height: 20)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Draw percentage change
        let percentageText = "Change in Coughs: \(String(format: "%.1f", abs(percentage)))%"
        let arrowSymbol = percentage > 0 ? "↑" : percentage < 0 ? "↓" : "–"
        
        let percentageFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let percentageColor = percentage > 0 ? UIColor.systemOrange : UIColor.systemBlue
        let percentageAttributes: [NSAttributedString.Key: Any] = [
            .font: percentageFont,
            .foregroundColor: percentageColor
        ]
        
        let percentageRect = CGRect(x: 65, y: yPosition + 45, width: cardWidth - 30, height: 20)
        "\(arrowSymbol) \(percentageText)".draw(in: percentageRect, withAttributes: percentageAttributes)
        
        // Draw peak time
        let peakTimeText = "Peak Time: \(peakTime)"
        let peakTimeFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let peakTimeAttributes: [NSAttributedString.Key: Any] = [
            .font: peakTimeFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let peakTimeRect = CGRect(x: 65, y: yPosition + 70, width: cardWidth - 30, height: 20)
        peakTimeText.draw(in: peakTimeRect, withAttributes: peakTimeAttributes)
        
        return yPosition + cardHeight
    }
    
    /// Draws the PDF header section
    static func drawHeader(in pageRect: CGRect) -> CGFloat {
        // Draw title
        let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleRect = CGRect(x: 50, y: 50, width: pageRect.width - 100, height: 40)
        "CoughSync Report".draw(in: titleRect, withAttributes: titleAttributes)
        
        // Add date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = "Generated on \(dateFormatter.string(from: Date()))"
        
        let dateFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let dateRect = CGRect(x: 50, y: 90, width: pageRect.width - 100, height: 20)
        dateString.draw(in: dateRect, withAttributes: dateAttributes)
        
        // Draw section title
        let sectionFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: sectionFont,
            .foregroundColor: UIColor.black
        ]
        
        let sectionRect = CGRect(x: 50, y: 130, width: pageRect.width - 100, height: 30)
        "Summary Reports".draw(in: sectionRect, withAttributes: sectionAttributes)
        
        return 170.0 // Return Y position after header
    }
    
    /// Draws the PDF footer
    static func drawFooter(in pageRect: CGRect) {
        let footerFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let footerRect = CGRect(x: 50, y: pageRect.height - 40, width: pageRect.width - 100, height: 20)
        "© CoughSync App - Confidential Health Information".draw(in: footerRect, withAttributes: footerAttributes)
    }
    
    /// Draws a section title
    static func drawSectionTitle(in pageRect: CGRect, at yPosition: CGFloat, title: String) -> CGFloat {
        let sectionFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: sectionFont,
            .foregroundColor: UIColor.black
        ]
        
        let sectionRect = CGRect(x: 50, y: yPosition, width: pageRect.width - 100, height: 30)
        title.draw(in: sectionRect, withAttributes: sectionAttributes)
        
        return yPosition + 40  // Return position after title
    }
}

// MARK: - Chart Drawing Functions
extension PDFDrawingHelpers {
    /// Draws a trend chart in the PDF document
    static func drawTrendChart(
        in rect: CGRect,
        at yPosition: CGFloat,
        title: String,
        data: [Int],
        xLabels: [String]
    ) -> CGFloat {
        // Draw chart title and background
        let (chartDrawRect, horizontalStep) = prepareChart(in: rect, at: yPosition, title: title, data: data)
        
        // Draw the chart axes and grid
        drawChartGrid(in: chartDrawRect, data: data)
        
        // Draw x-axis labels
        drawXAxisLabels(in: chartDrawRect, labels: xLabels, horizontalStep: horizontalStep)
        
        // Draw the data line
        drawDataLine(in: chartDrawRect, data: data, horizontalStep: horizontalStep)
        
        return yPosition + 200 + 30 // Chart height + padding
    }
    
    /// Prepares chart background and title
    private static func prepareChart(
        in rect: CGRect,
        at yPosition: CGFloat,
        title: String,
        data: [Int]
    ) -> (drawRect: CGRect, horizontalStep: CGFloat) {
        let pageWidth = rect.width
        let chartWidth = pageWidth - 100
        let chartHeight: CGFloat = 200
        
        // Draw title
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleRect = CGRect(x: 50, y: yPosition, width: chartWidth, height: 20)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Draw chart background
        let chartRect = CGRect(x: 50, y: yPosition + 30, width: chartWidth, height: chartHeight)
        let chartPath = UIBezierPath(roundedRect: chartRect, cornerRadius: 8)
        UIColor.white.setFill()
        chartPath.fill()
        
        UIColor.systemGray5.setStroke()
        chartPath.lineWidth = 1
        chartPath.stroke()
        
        // Calculate chart metrics
        let padding: CGFloat = 40
        let chartDrawRect = chartRect.insetBy(dx: padding, dy: padding)
        let horizontalStep = chartDrawRect.width / CGFloat(max(1, data.count - 1))
        
        return (chartDrawRect, horizontalStep)
    }
    
    /// Draws chart grid lines and axes
    private static func drawChartGrid(in chartDrawRect: CGRect, data: [Int]) {
        let maxValue = data.max() ?? 100
        
        // Draw axes
        let axisPath = UIBezierPath()
        axisPath.move(to: CGPoint(x: chartDrawRect.minX, y: chartDrawRect.minY))
        axisPath.addLine(to: CGPoint(x: chartDrawRect.minX, y: chartDrawRect.maxY))
        axisPath.addLine(to: CGPoint(x: chartDrawRect.maxX, y: chartDrawRect.maxY))
        UIColor.darkGray.setStroke()
        axisPath.lineWidth = 1
        axisPath.stroke()
        
        // Draw horizontal grid lines and y-axis labels
        let gridLineCount = 5
        let verticalStep = chartDrawRect.height / CGFloat(gridLineCount - 1)
        let valueStep = Double(maxValue) / Double(gridLineCount - 1)
        
        let gridLinePath = UIBezierPath()
        let yLabelFont = UIFont.systemFont(ofSize: 10)
        let yLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: yLabelFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        for lineIndex in 0..<gridLineCount {
            let verticalPosition = chartDrawRect.maxY - CGFloat(lineIndex) * verticalStep
            
            // Grid line
            gridLinePath.move(to: CGPoint(x: chartDrawRect.minX, y: verticalPosition))
            gridLinePath.addLine(to: CGPoint(x: chartDrawRect.maxX, y: verticalPosition))
            
            // Y-axis label
            let labelValue = Int(Double(lineIndex) * valueStep)
            let labelString = "\(labelValue)"
            let labelSize = labelString.size(withAttributes: yLabelAttributes)
            let labelRect = CGRect(
                x: chartDrawRect.minX - labelSize.width - 5,
                y: verticalPosition - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )
            labelString.draw(in: labelRect, withAttributes: yLabelAttributes)
        }
        
        UIColor.systemGray4.setStroke()
        gridLinePath.lineWidth = 0.5
        gridLinePath.stroke()
    }
    
    /// Draws x-axis labels for the chart
    private static func drawXAxisLabels(
        in chartDrawRect: CGRect,
        labels: [String],
        horizontalStep: CGFloat
    ) {
        let xLabelFont = UIFont.systemFont(ofSize: 10)
        let xLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: xLabelFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        for (itemIndex, label) in labels.enumerated() {
            let horizontalPosition = chartDrawRect.minX + CGFloat(itemIndex) * horizontalStep
            let labelSize = label.size(withAttributes: xLabelAttributes)
            let labelRect = CGRect(
                x: horizontalPosition - labelSize.width / 2,
                y: chartDrawRect.maxY + 5,
                width: labelSize.width,
                height: labelSize.height
            )
            label.draw(in: labelRect, withAttributes: xLabelAttributes)
        }
    }
    
    /// Draws the data line and points on the chart
    private static func drawDataLine(
        in chartDrawRect: CGRect,
        data: [Int],
        horizontalStep: CGFloat
    ) {
        if data.count <= 1 { return }
        
        let maxValue = data.max() ?? 100
        let linePath = UIBezierPath()
        let pointRadius: CGFloat = 3
        
        // Calculate normalized points
        var dataPoints: [CGPoint] = []
        for (itemIndex, value) in data.enumerated() {
            let horizontalPosition = chartDrawRect.minX + CGFloat(itemIndex) * horizontalStep
            let normalizedValue = CGFloat(value) / CGFloat(maxValue)
            let verticalPosition = chartDrawRect.maxY - normalizedValue * chartDrawRect.height
            dataPoints.append(CGPoint(x: horizontalPosition, y: verticalPosition))
        }
        
        // Draw the line
        linePath.move(to: dataPoints[0])
        for pointIndex in 1..<dataPoints.count {
            linePath.addLine(to: dataPoints[pointIndex])
        }
        
        UIColor.blue.setStroke()
        linePath.lineWidth = 2
        linePath.stroke()
        
        // Draw data points
        for dataPoint in dataPoints {
            let pointPath = UIBezierPath(arcCenter: dataPoint, radius: pointRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            UIColor.blue.setFill()
            pointPath.fill()
        }
    }
}
