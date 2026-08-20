# SonicField

> Real-time 360° spatial sound localization and acoustic field intelligence for Apple Silicon MacBooks.

---

## Overview

**SonicField** is a native macOS application that uses Apple Silicon MacBook built-in microphone systems to detect the spatial direction of human speech around the laptop across **8 directional sectors**:

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

Inspired by research into multi-microphone array localization, SonicField combines direct **Core Audio hardware capability discovery**, accelerated **vDSP signal processing**, dynamic **Voice Activity Detection (VAD)**, and distance-based **feature vector classification** with Softmax confidence scoring and out-of-distribution **UNKNOWN rejection**.

---

## Key Features

- **Core Audio Hardware Inspector**: Queries stream format, sample rates, channel counts, and computes pairwise Pearson cross-correlation matrices ($CH_i \leftrightarrow CH_j$) to discover whether host channels are independent or pre-processed beamformed array streams.
- **vDSP Signal Processing Engine**: Hann-windowed real-to-complex FFT, 24+ time/frequency/spatial features (RMS, Peak, Zero-Crossing Rate, Spectral Centroid, Spectral Rolloff, 8 Sub-band energies, 12 Log-Mel filterbank MFCCs, GCC-PHAT TDOA).
- **Adaptive Voice Activity Detector (VAD)**: Real-time dynamic noise-floor tracking and SNR energy thresholding to isolate human speech from ambient room noise, silence, and keyboard clicks.
- **Room & Laptop Calibration Wizard**: Step-by-step interactive wizard for calibrating 4-zone and 8-zone spatial profiles adapted to specific rooms, desk surfaces, and laptop positions, with local JSON persistence (`Application Support/SonicField/Profiles/`).
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
                    └────────────────────────────┘
```

---

## Directory Structure

```
SonicField/
├── Package.swift                  # Swift Package Manager manifest
├── ProjectDetails.md              # Complete technical architecture specification
├── README.md                      # Product documentation & usage guide
├── Sources/
│   ├── SonicFieldApp/
│   │   └── main.swift             # Main SwiftUI application entry point
│   └── SonicFieldKit/
│       ├── App/                   # AppState coordinator & MainView container
│       ├── Audio/                 # Core Audio hardware inspector & AVAudioEngine capture
│       ├── Calibration/           # Calibration wizard & JSON profile manager
│       ├── DSP/                   # vDSP FFT, Feature Extractor & GCC-PHAT TDOA
│       ├── Detection/             # Dynamic noise-floor Voice Activity Detector (VAD)
│       ├── Diagnostics/           # Core Audio diagnostic view & report generator
│       ├── Evaluation/            # Empirical benchmark runner & confusion matrix
│       ├── Localization/          # Spatial directions, distance classifier & smoother
│       └── Visualization/         # Spatial radar UI, MacBook icon & sound wave canvas
├── Tests/
│   └── SonicFieldTests/           # Unit test suite (DSP, VAD, Classifier, Calibration)
├── docs/                          # Architecture guardrails & standards
└── scripts/
    ├── build.sh                   # Native swiftc build script for executable & tests
    ├── check-guardrails.sh        # Automated engineering guardrail suite
    └── setup-guardrails.sh        # Local git hooks setup script
```

---

## Quick Start Guide

### Prerequisites

- **macOS 14.0+** (macOS 15 Sequoia recommended)
- **Apple Silicon Mac** (M1/M2/M3/M4)
- Swift 5.9+ / Swift 6 toolchain (`swiftc`)

### 1. Initialize Local Engineering Guardrails

```bash
./scripts/setup-guardrails.sh
```

### 2. Build the Application and Test Runner

```bash
./scripts/build.sh
```

This compiles two native executables into `bin/`:
- `bin/SonicField`: The native macOS SwiftUI application.
- `bin/SonicFieldTests`: The automated unit test suite runner.

### 3. Run Automated Unit Tests

```bash
./bin/SonicFieldTests
```

### 4. Run Engineering Guardrail Validation

```bash
./scripts/check-guardrails.sh
```

### 5. Launch the SonicField Application

```bash
./bin/SonicField
```

---

## Framework Integration API (`SonicFieldKit`)

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

## Engineering Guardrail Standards

This project enforces strict engineering guardrails:

- **Baseline Branch**: All changes are cut from and merged into `development`.
- **Branch Naming**: `<PROJECT_INITIALS>-<NUMBER>` (e.g. `SF-01`, `SF-02`).
- **Commit Format**: [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`).
- **Secret Hygiene**: Zero secret credentials or environment files tracked in git.
- **UI Iconography**: SVG and native vector rendering only (no emojis as UI icons).

---

## License

This project is licensed under the [MIT License](LICENSE).
