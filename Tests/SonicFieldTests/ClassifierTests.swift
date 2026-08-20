import Foundation

public struct ClassifierTests {
    public init() {}

    public func testClassifierPredictionAndRejection() {
        let classifier = DirectionClassifier(minConfidenceThreshold: 0.40)

        let frontVec = FeatureVector(
            rms: 0.1, peak: 0.2, zeroCrossingRate: 0.1,
            spectralCentroid: 1000.0, spectralRolloff: 2000.0,
            bandEnergies: [1, 0, 0, 0, 0, 0, 0, 0], mfccs: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        )

        let rightVec = FeatureVector(
            rms: 0.1, peak: 0.2, zeroCrossingRate: 0.1,
            spectralCentroid: 5000.0, spectralRolloff: 8000.0,
            bandEnergies: [0, 0, 0, 0, 1, 0, 0, 0], mfccs: [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
        )

        let profile = CalibrationProfile(
            name: "Test Profile",
            zoneSamples: [
                .front: [frontVec, frontVec],
                .right: [rightVec, rightVec]
            ]
        )

        classifier.loadProfile(profile)

        let inputFront = FeatureVector(
            rms: 0.1, peak: 0.2, zeroCrossingRate: 0.1,
            spectralCentroid: 1050.0, spectralRolloff: 2050.0,
            bandEnergies: [0.95, 0.05, 0, 0, 0, 0, 0, 0], mfccs: [0.95, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        )

        let pred = classifier.classify(featureVector: inputFront)
        assert(pred.direction == .front, "Classifier should predict FRONT")
        assert(pred.confidence > 0.5, "Classifier confidence should be high")
    }

    public func testTemporalSmoother() {
        let smoother = TemporalSmoother(alpha: 0.5, historyWindowSize: 3)
        let pred = PredictionResult(
            direction: .frontRight,
            confidence: 0.85,
            zoneProbabilities: [.frontRight: 0.85, .front: 0.15],
            isAmbiguous: false,
            rawDistance: 0.1
        )

        let smoothed = smoother.smooth(prediction: pred)
        assert(smoothed.direction == .frontRight, "Smoother should output FRONT-RIGHT")
    }
}
