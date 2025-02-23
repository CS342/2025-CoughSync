//
//  CoughDetectionConfiguration.swift
//  CoughSync
//
//  Created by Miguel Fuentes on 2/23/25.
//

import CoreMedia
import Foundation


/// Configuration parameters for the cough detection analysis.
///
/// This struct defines the settings for analyzing audio streams to detect coughs,
/// including the analysis window size, overlap factor, and timescale for processing.
///
/// - Parameters:
///   - `windowSize`: The duration of each analysis window in seconds.
///   - `overlapFactor`: The proportion of overlap between consecutive windows, ranging from `0.0` (no overlap) to `1.0` (complete overlap).
///   - `timescale`: The timescale representing the number of samples per second, typically aligned with the audio sample rate.
struct CoughDetectionConfiguration {
    let windowSize: Double  // In seconds
    let overlapFactor: Double  // 0.0 - 1.0
    var timescale: CMTimeScale // Default timescale (samples per second)
    
    /// Initializes a new configuration for cough detection analysis.
    ///
    /// - Parameters:
    ///   - `windowSize`: The duration of each analysis window in seconds. Default is `1.0` second.
    ///   - `overlapFactor`: The fraction of overlap between analysis windows. Default is `0.5` (50% overlap).
    ///   - `timescale`: The timescale defining the number of samples per second. Default is `48,000` (common for high-quality audio).
    init(
        windowSize: Double = 1.0,
        overlapFactor: Double = 0.5,
        timescale: CMTimeScale = 48_000
    ) {
        self.windowSize = windowSize
        self.overlapFactor = overlapFactor
        self.timescale = timescale
    }
}
