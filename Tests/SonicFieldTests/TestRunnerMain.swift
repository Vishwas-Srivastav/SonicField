import Foundation

@main
struct TestRunnerMain {
    static func main() {
        print("==================================================")
        print("       SONICFIELD UNIT TEST SUITE RUNNER         ")
        print("==================================================")

        var passedCount = 0
        var failedCount = 0

        func runTest(_ name: String, block: () throws -> Void) {
            print("\n[TEST] Running \(name)...")
            do {
                try block()
                print("[PASS] \(name)")
                passedCount += 1
            } catch {
                print("[FAIL] \(name): \(error.localizedDescription)")
                failedCount += 1
            }
        }

        // 1. DSP Tests
        let dspTests = DSPTests()
        runTest("testAudioFrameRMSAndPeak") { dspTests.testAudioFrameRMSAndPeak() }
        runTest("testZeroCrossingRate") { dspTests.testZeroCrossingRate() }
        runTest("testSubBandEnergies") { dspTests.testSubBandEnergies() }
        runTest("testFFTProcessorSineWave") { dspTests.testFFTProcessorSineWave() }
        runTest("testGCCPHATSameChannel") { dspTests.testGCCPHATSameChannel() }

        // 2. VAD Tests
        let vadTests = VADTests()
        runTest("testVADSilenceRejection") { vadTests.testVADSilenceRejection() }
        runTest("testVADSpeechDetection") { vadTests.testVADSpeechDetection() }

        // 3. Classifier Tests
        let classifierTests = ClassifierTests()
        runTest("testClassifierPredictionAndRejection") { classifierTests.testClassifierPredictionAndRejection() }
        runTest("testTemporalSmoother") { classifierTests.testTemporalSmoother() }

        // 4. Tap Detector & Action Manager Tests
        let tapTests = TapDetectorTests()
        runTest("testTapDetectorImpulsivePeak") { tapTests.testTapDetectorImpulsivePeak() }
        runTest("testTapDetectorVoiceRejection") { tapTests.testTapDetectorVoiceRejection() }

        let actionTests = ActionManagerTests()
        runTest("testActionManagerConfigurationAndDispatch") { actionTests.testActionManagerConfigurationAndDispatch() }
        runTest("testActionManagerDisabledQuadrant") { actionTests.testActionManagerDisabledQuadrant() }

        print("\n==================================================")
        if failedCount == 0 {
            print(" ✓ ALL \(passedCount) UNIT TESTS PASSED!")
            print("==================================================")
        } else {
            print(" ✗ \(failedCount) UNIT TESTS FAILED!")
            print("==================================================")
            exit(1)
        }
    }
}
