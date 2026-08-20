import Foundation

public struct DSPTests {
    public init() {}

    public func testAudioFrameRMSAndPeak() {
        let channel1: [Float] = [0.1, -0.1, 0.2, -0.2]
        let frame = AudioFrame(
            sampleRate: 48000,
            channelCount: 1,
            frameCount: 4,
            samples: [channel1]
        )

        assert(frame.channelCount == 1, "Channel count mismatch")
        assert(frame.frameCount == 4, "Frame count mismatch")
        assert(frame.rms[0] > 0.0, "RMS should be positive")
        assert(abs(frame.peak[0] - 0.2) < 1e-4, "Peak mismatch")
    }

    public func testZeroCrossingRate() {
        let extractor = FeatureExtractor()
        let alternating: [Float] = [1.0, -1.0, 1.0, -1.0, 1.0, -1.0]
        let zcr = extractor.computeZeroCrossingRate(samples: alternating)
        assert(abs(zcr - 1.0) < 1e-4, "ZCR alternating mismatch")

        let allPositive: [Float] = [1.0, 1.0, 1.0, 1.0]
        let zcrPos = extractor.computeZeroCrossingRate(samples: allPositive)
        assert(abs(zcrPos - 0.0) < 1e-4, "ZCR positive mismatch")
    }

    public func testSubBandEnergies() {
        let extractor = FeatureExtractor()
        let spectrum: [Float] = Array(repeating: 1.0, count: 64)
        let bands = extractor.computeSubBandEnergies(spectrum: spectrum, numBands: 8)
        assert(bands.count == 8, "Band count mismatch")
        for band in bands {
            assert(abs(band - 1.0) < 1e-4, "Sub-band energy mismatch")
        }
    }

    public func testFFTProcessorSineWave() {
        let fft = FFTProcessor(fftSize: 256)
        var sineWave = [Float](repeating: 0, count: 256)
        for i in 0..<256 {
            sineWave[i] = sin(2.0 * Float.pi * 10.0 * Float(i) / 256.0)
        }
        let mag = fft.computeMagnitudeSpectrum(samples: sineWave)
        assert(mag.count == 128, "FFT output bin count mismatch")
        assert(mag[10] > 0.0, "FFT magnitude peak mismatch")
    }

    public func testGCCPHATSameChannel() {
        let gcc = GCCPHAT(fftSize: 256)
        let ch1: [Float] = (0..<256).map { sin(Float($0) * 0.1) }
        let lag = gcc.computeTDOA(ch1: ch1, ch2: ch1)
        assert(lag == 0, "GCC-PHAT identical channel lag should be 0")
    }
}
