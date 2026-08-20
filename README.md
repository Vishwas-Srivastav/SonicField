# SonicField

> Real-time 360° spatial sound localization and acoustic field intelligence for Apple Silicon MacBooks.

---

> 🚀 **Open Source & Active Development**: SonicField is actively being developed as an open-source spatial audio intelligence framework. Core Audio diagnostic discovery, vDSP signal processing, room calibration, and the 360° spatial radar visualizer are fully functional. Community contributions, feature ideas, and hardware diagnostic reports across different Mac models are warmly welcomed!

---

## Overview

**SonicField** is a native macOS application and developer framework (`SonicFieldKit`) that leverages Apple Silicon MacBook built-in microphone arrays to detect the spatial direction of human speech in real time across **8 directional sectors**:

```
                     FRONT
                       0°
                       ▲
              FRONT-LEFT    FRONT-RIGHT
                 315°          45°
 LEFT 270° ───────── [MACBOOK] ───────── 90° RIGHT
              REAR-LEFT     REAR-RIGHT
                 225°         135°
                       ▼
                      180°
                      REAR
```

Combining direct **Core Audio hardware discovery**, accelerated **vDSP signal processing**, dynamic **Voice Activity Detection (VAD)**, and distance-based **feature vector classification** with Softmax confidence scoring and out-of-distribution **UNKNOWN rejection**, SonicField provides real-time acoustic spatial awareness.

---

## Project Status & Roadmap

| Milestone / Feature | Status | Description |
| :--- | :---: | :--- |
| **Core Audio Hardware Inspector** | ✅ Completed | C-API property querying, stream format inspection, RMS/Peak meters, Pearson channel correlation ($CH_i \leftrightarrow CH_j$). |
| **DSP Feature Extraction** | ✅ Completed | Accelerated vDSP FFT, ZCR, Spectral Centroid/Rolloff, 8 sub-bands, 12-band MFCCs, GCC-PHAT TDOA. |
| **Adaptive Noise Floor VAD** | ✅ Completed | Dynamic SNR thresholding isolating speech from ambient noise & keyboard clicks. |
| **Calibration Wizard & Profiles** | ✅ Completed | Interactive 4-zone & 8-zone room calibration with JSON profile persistence. |
| **Spatial Radar Visualizer** | ✅ Completed | SwiftUI 360° radar with vector MacBook icon, active sector highlight & animated sound waves. |
| **Empirical Benchmark Suite** | ✅ Completed | Automated evaluation runner generating confusion matrices & accuracy metrics. |
| **CoreML Spatial Neural Classifier** | ⏳ In Progress | On-device lightweight neural network for fine-grained 360° azimuth estimation. |
| **Multi-Speaker Diarization** | 📅 Planned | Tagging transcribed audio streams by spatial origin sector around the laptop. |

---

## Key Features

- **Core Audio Hardware Inspector**: Direct C-API property querying (`AudioObjectGetPropertyData`), stream format inspection, real-time per-channel RMS/Peak meters, and pairwise Pearson cross-correlation matrices ($CH_i \leftrightarrow CH_j$).
- **vDSP Signal Processing Engine**: Accelerated Hann-windowed FFT, 24+ time/frequency/spatial features (RMS, Peak, Zero-Crossing Rate, Spectral Centroid, Spectral Rolloff, 8 Sub-band energies, 12 Log-Mel filterbank MFCCs, GCC-PHAT TDOA).
- **Adaptive Voice Activity Detector (VAD)**: Real-time dynamic noise-floor tracking and SNR energy thresholding to isolate human speech from ambient room noise, silence, and keyboard clicks.
- **Room & Laptop Calibration Wizard**: Guided interactive wizard for calibrating 4-zone and 8-zone spatial profiles adapted to specific rooms, desk surfaces, and laptop placements, with local JSON persistence (`Application Support/SonicField/Profiles/`).
- **Softmax Classification & UNKNOWN Rejection**: Distance-based cluster centroid matching with Softmax confidence scoring, margin thresholding, and negative sample noise rejection to prevent false zone locks on ambient sounds.
- **Rolling Probability Temporal Hysteresis**: Exponential Moving Average (EMA) and rolling prediction window to eliminate erratic UI flickering between adjacent spatial sectors.
- **SwiftUI 360° Spatial Radar Dashboard**: Real-time spatial UI featuring a vector MacBook center icon, active sector highlight, animated radial sound waves, speech signal status, and JSON/Markdown diagnostic report exporter.
- **Benchmark & Evaluation Suite**: Empirical benchmark utility generating confusion matrices, per-zone accuracy, precision/recall, and unknown rate statistics.

---

## Application Architecture

```
                    ┌────────────────────────────┐
                    │     MacBook Microphone     │
                    │       Core Audio API       │
                    └──────────────┬─────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │    Audio Capture Service   │
                    │   (AVAudioEngine 48kHz)    │
                    └──────────────┬─────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │  Voice Activity Detector   │
                    │  (Dynamic Noise Floor VAD) │
                    └──────────────┬─────────────┘
                                   │
                                   ▼
               ┌───────────────────┴───────────────────┐
               │                                       │
               ▼                                       ▼
    Time-Domain Features                 Frequency & Spatial Features
    (RMS, Peak, ZCR)                     (FFT, Centroid, MFCC, GCC-PHAT)
               │                                       │
               └───────────────────┬───────────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │ Directional Classifier &   │
                    │    Confidence Estimator    │
                    └──────────────┬─────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │     Temporal Smoother      │
                    │  (EMA Hysteresis Window)   │
                    └──────────────┬─────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │ SwiftUI Spatial Field UI   │
                    │    (360° Radar & Waves)    │
                    └──────────────┬─────────────┘
```

---

## Quick Start Guide

### Prerequisites

- **macOS 14.0+** (macOS 15 Sequoia recommended)
- **Apple Silicon Mac** (M1/M2/M3/M4)
- Swift 5.9+ / Swift 6 toolchain (`swiftc`)

### 1. Build Application & Test Runner

```bash
./scripts/build.sh
```

This compiles two native executables into `bin/`:
- `bin/SonicField`: The native macOS SwiftUI application.
- `bin/SonicFieldTests`: The automated unit test suite runner.

### 2. Run Automated Unit Tests

```bash
./bin/SonicFieldTests
```

### 3. Launch SonicField App

```bash
./bin/SonicField
```

---

## Using `SonicFieldKit` in Swift Applications

You can import `SonicFieldKit` into any macOS application to add real-time spatial voice direction awareness:

```swift
import SonicFieldKit

// 1. Initialize application state coordinator
let appState = AppState()

// 2. Start real-time microphone capture
appState.startCapture()

// 3. Subscribe to real-time directional sound events
appState.$currentPrediction
    .sink { prediction in
        guard prediction.direction != .unknown else { return }
        
        print("Detected Voice Direction: \(prediction.direction.rawValue)")
        print("Prediction Confidence: \(Int(prediction.confidence * 100))%")
    }
```

---

## Contributing & Hardware Diagnostics

We encourage community members to run SonicField on various Mac hardware configurations (MacBook Air / Pro, M1 through M4) and share diagnostic reports!

- **Diagnostic Reports**: Run Tab 1 (Diagnostics Mode) and click **"Export Markdown Report"**. Attach the report to a GitHub Issue or Discussion.
- **Pull Requests**: Please review [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/GUARDRAILS.md](docs/GUARDRAILS.md) before submitting code.

---

## License

This project is licensed under the [MIT License](LICENSE).
