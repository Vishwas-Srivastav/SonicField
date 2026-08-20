# SonicField

> Real-time 360-degree spatial sound localization, acoustic field intelligence, and surface tap detection for Apple Silicon MacBooks.

---

## Overview

**SonicField** is a native macOS application and developer framework (`SonicFieldKit`) that leverages Apple Silicon MacBook built-in microphone arrays to detect the spatial direction of human speech and physical desk surface taps across **8 directional sectors** and **4 laptop surface quadrants**:

```
                      Display Side (Hinge)
           ┌────────────────────────────────────────┐
  Left     │               [ MACBOOK ]              │    Right
  Rear     │                                        │    Rear
 (270°..315°)│  Left Speaker         Right Speaker  │ (45°..90°)
           ├────────────────────────────────────────┤
  Left     │                [ Trackpad ]            │    Right
  Front    │                                        │    Front
(225°..270°)└────────────────────────────────────────┘(90°..135°)
                      Trackpad Side (User)
```

Combining direct **Core Audio hardware discovery**, accelerated **vDSP signal processing**, dynamic **Voice Activity Detection (VAD)**, transient **Acoustic Tap Detection**, and distance-based **feature vector classification** with Softmax confidence scoring and out-of-distribution **UNKNOWN rejection**, SonicField provides real-time acoustic spatial awareness and action triggering.

---

## Project Status & Roadmap

| Milestone / Feature | Status | Description |
| :--- | :---: | :--- |
| **Core Audio Hardware Inspector** | Completed | C-API property querying, stream format inspection, RMS/Peak meters, Pearson channel correlation ($CH_i \leftrightarrow CH_j$). |
| **DSP Feature Extraction** | Completed | Accelerated vDSP FFT, ZCR, Spectral Centroid/Rolloff, 8 sub-bands, 12-band MFCCs, GCC-PHAT TDOA. |
| **Adaptive Noise Floor VAD** | Completed | Dynamic SNR thresholding isolating speech from ambient noise & keyboard clicks. |
| **Acoustic Tap Action Engine** | Completed | Impulsive transient detector & configurable macOS action triggers (Screenshot, Input Mute, App Launch). |
| **Calibration Wizard & Profiles** | Completed | Interactive 4-zone & 8-zone room calibration with JSON profile persistence. |
| **Spatial Radar Visualizer** | Completed | SwiftUI 360-degree radar with vector MacBook icon, active sector highlight & animated sound waves. |
| **Empirical Benchmark Suite** | Completed | Automated evaluation runner generating confusion matrices & accuracy metrics. |
| **CoreML Spatial Neural Classifier** | In Progress | On-device lightweight neural network for fine-grained 360-degree azimuth estimation. |
| **Multi-Speaker Diarization** | Planned | Tagging transcribed audio streams by spatial origin sector around the laptop. |

---

## Key Features

- **Core Audio Hardware Inspector**: Direct C-API property querying (`AudioObjectGetPropertyData`), stream format inspection, real-time per-channel RMS/Peak meters, and pairwise Pearson cross-correlation matrices ($CH_i \leftrightarrow CH_j$).
- **vDSP Signal Processing Engine**: Accelerated Hann-windowed FFT, 24+ time/frequency/spatial features (RMS, Peak, Zero-Crossing Rate, Spectral Centroid, Spectral Rolloff, 8 Sub-band energies, 12 Log-Mel filterbank MFCCs, GCC-PHAT TDOA).
- **Adaptive Voice Activity Detector (VAD)**: Real-time dynamic noise-floor tracking and SNR energy thresholding to isolate human speech from ambient room noise, silence, and keyboard clicks.
- **Acoustic Desk Tap Detector**: High-frequency transient onset detector ($\text{Peak} / \text{RMS} \ge 5.5$) isolating physical surface impacts from voice speech.
- **Configurable Action Trigger Engine**: Maps desk tap quadrants (*Left Front*, *Left Rear*, *Right Front*, *Right Rear*) to native macOS tasks (Screenshots, Input Volume Mute, App Launchers, Zsh Scripts).
- **Room & Laptop Calibration Wizard**: Guided interactive wizard for calibrating 4-zone and 8-zone spatial profiles adapted to specific rooms, desk surfaces, and laptop placements, with local JSON persistence (`Application Support/SonicField/Profiles/`).
- **Softmax Classification & UNKNOWN Rejection**: Distance-based cluster centroid matching with Softmax confidence scoring, margin thresholding, and negative sample noise rejection to prevent false zone locks on ambient sounds.
- **Rolling Probability Temporal Hysteresis**: Exponential Moving Average (EMA) and rolling prediction window to eliminate erratic UI flickering between adjacent spatial sectors.
- **SwiftUI 360-Degree Spatial Radar Dashboard**: Real-time spatial UI featuring a vector MacBook center icon, active sector highlight, surface quadrant status, animated radial sound waves, and action configurator tab.
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
              ┌────────────────────┴────────────────────┐
              │                                         │
              ▼                                         ▼
  Voice Activity Detector                      Tap Detector
 (Dynamic Noise Floor VAD)                (Transient Onset Engine)
              │                                         │
              ▼                                         ▼
   Spatial Feature Extractor                 Action Trigger Engine
 (FFT, Centroid, MFCC, GCC-PHAT)           (Screenshot, Mute, Apps)
              │                                         │
              └────────────────────┬────────────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │ Directional Classifier &   │
                    │    Confidence Estimator    │
                    └──────────────┬─────────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │ SwiftUI Spatial Field UI   │
                    │   (360° Radar & Actions)   │
                    └────────────────────────────┘
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

You can import `SonicFieldKit` into any macOS application to add real-time spatial voice direction awareness and acoustic tap triggers:

```swift
import SonicFieldKit

// 1. Initialize application state coordinator
let appState = AppState()

// 2. Configure action mappings (e.g. Right Front tap -> Take Screenshot)
appState.actionManager.setAction(.takeScreenshot, for: .rightFront)
appState.actionManager.setAction(.toggleMute, for: .leftFront)

// 3. Start real-time microphone capture
appState.startCapture()

// 4. Subscribe to real-time directional sound events
appState.$currentPrediction
    .sink { prediction in
        guard prediction.direction != .unknown else { return }
        print("Detected Voice Direction: \(prediction.direction.rawValue)")
        print("Laptop Surface Quadrant: \(prediction.direction.laptopQuadrant.rawValue)")
    }
```

---

## Contributing & Hardware Diagnostics

We encourage community members to run SonicField on various Mac hardware configurations (MacBook Air / Pro, M1 through M4) and share diagnostic reports.

- **Diagnostic Reports**: Run Tab 1 (Diagnostics Mode) and click **"Export Markdown Report"**. Attach the report to a GitHub Issue or Discussion.
- **Pull Requests**: Please review [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/GUARDRAILS.md](docs/GUARDRAILS.md) before submitting code.

---

## License

This project is licensed under the [MIT License](LICENSE).
