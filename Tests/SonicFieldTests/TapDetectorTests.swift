import Foundation

public struct TapDetectorTests {
    public init() {}

    public func testTapDetectorImpulsivePeak() {
        let detector = TapDetector()
        var impulsiveSamples = [Float](repeating: 0.001, count: 1024)
        for i in 10..<15 {
            impulsiveSamples[i] = 0.85
        }

        let frame = AudioFrame(
            sampleRate: 48000,
            channelCount: 1,
            frameCount: 1024,
            samples: [impulsiveSamples]
        )
        let features = FeatureVector(
            rms: 0.08,
            peak: 0.85,
            zeroCrossingRate: 0.35,
            spectralCentroid: 4000,
            spectralRolloff: 6000,
            bandEnergies: [Float](repeating: 1.0, count: 8),
            mfccs: [Float](repeating: 0.5, count: 12)
        )

        let isTap = detector.detectTap(in: frame, features: features)
        assert(isTap, "TapDetector should detect high peak-to-RMS impulsive desk tap")
    }

    public func testTapDetectorVoiceRejection() {
        let detector = TapDetector()
        let voiceSamples = [Float](repeating: 0.2, count: 1024)
        let frame = AudioFrame(
            sampleRate: 48000,
            channelCount: 1,
            frameCount: 1024,
            samples: [voiceSamples]
        )
        let features = FeatureVector(
            rms: 0.2,
            peak: 0.22,
            zeroCrossingRate: 0.05,
            spectralCentroid: 1500,
            spectralRolloff: 2500,
            bandEnergies: [Float](repeating: 0.5, count: 8),
            mfccs: [Float](repeating: 0.2, count: 12)
        )

        let isTap = detector.detectTap(in: frame, features: features)
        assert(!isTap, "TapDetector should reject continuous low peak-to-RMS voice frames")
    }
}
