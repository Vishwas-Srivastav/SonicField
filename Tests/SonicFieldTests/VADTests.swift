import Foundation

public struct VADTests {
    public init() {}

    public func testVADSilenceRejection() {
        let vad = VoiceActivityDetector(config: VADConfiguration(minEnergyThreshold: 0.05))
        let silentSamples = [Float](repeating: 0.001, count: 512)
        let silentFrame = AudioFrame(sampleRate: 48000, channelCount: 1, frameCount: 512, samples: [silentSamples])

        let isSpeech = vad.processFrame(silentFrame)
        assert(!isSpeech, "VAD should reject silence audio frames")
    }

    public func testVADSpeechDetection() {
        let vad = VoiceActivityDetector(config: VADConfiguration(minEnergyThreshold: 0.01, minSpeechFrames: 1))
        let loudSamples = [Float](repeating: 0.3, count: 512)
        let loudFrame = AudioFrame(sampleRate: 48000, channelCount: 1, frameCount: 512, samples: [loudSamples])

        let isSpeech = vad.processFrame(loudFrame)
        assert(isSpeech, "VAD should detect speech on loud energy audio frames")
    }
}
