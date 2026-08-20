MacBook Spatial Sound Localization

1. Project Overview

Build a native macOS application that uses the MacBook’s built-in microphone and audio system to detect the approximate direction from which a person is speaking around the MacBook.

The application should visualize the MacBook as the center of an 8-direction spatial field:

* Front
* Front-Left
* Front-Right
* Left
* Right
* Rear
* Rear-Left
* Rear-Right

The primary objective is direction classification, not precise 3D positioning.

The project should be inspired by the architecture and experimental methodology of:

https://github.com/JustinGamer191/Holo

Holo demonstrates that useful spatial classification can be performed using the MacBook’s built-in microphone system without assuming that third-party applications have direct access to each physical microphone capsule.

Do not assume that macOS exposes independent raw microphone channels. The implementation must first inspect what the actual MacBook audio device exposes.

⸻

2. Core Objective

Given:

A person speaks from somewhere around the MacBook.

The system should produce:

Direction: FRONT-RIGHT
Confidence: 87%

and visually highlight the corresponding zone.

Example:

                         FRONT
                           ▲
                           │
                    ┌──────┴──────┐
                    │             │
              FRONT-LEFT      FRONT-RIGHT
                    │      🔊     │
                    │             │
LEFT ───────────────┤   MACBOOK   ├────────────── RIGHT
                    │             │
              REAR-LEFT       REAR-RIGHT
                    │             │
                    └──────┬──────┘
                           │
                           ▼
                          REAR

The system should also support an UNKNOWN state when confidence is insufficient.

⸻

3. Important Technical Constraint

Do not design the project around the assumption:

Mic 1 = Front
Mic 2 = Rear
Mic 3 = Side

or:

Channel 1 = physical microphone 1
Channel 2 = physical microphone 2
Channel 3 = physical microphone 3

macOS may expose the built-in microphone array as an aggregate or processed input rather than independent physical microphone streams.

Therefore the first milestone is audio-device capability discovery.

The application must determine:

* available input devices
* input channel count
* sample rate
* channel layout
* channel descriptions
* stream format
* whether multiple channels contain independently useful information
* whether the audio stream appears processed/beamformed
* whether the system can access useful spatial information

Do not make unsupported assumptions.

⸻

4. Reference Project

Study the following repository before implementing the project:

https://github.com/JustinGamer191/Holo

Important concepts to investigate from Holo:

* Core Audio input handling
* real-time audio capture
* audio windows
* onset/sound detection
* FFT processing
* acoustic feature extraction
* calibration
* zone classification
* confidence scoring
* ambiguity rejection
* negative examples
* out-of-distribution rejection
* diagnostics
* persistence
* evaluation methodology

Do not blindly copy code.

Understand the architecture and adapt appropriate ideas for speech-source localization.

⸻

5. Recommended Technology

Use a native macOS application.

Preferred stack:

Language:
Swift
UI:
SwiftUI
Audio:
AVFAudio / AVAudioEngine
Core Audio where required
DSP:
Accelerate / vDSP
ML:
Core ML where appropriate
Testing:
XCTest
Minimum target:
macOS version compatible with the development environment

Avoid unnecessary external dependencies.

The project should remain lightweight and suitable for running locally on an Apple Silicon MacBook.

⸻

6. High-Level Architecture

Use a modular architecture:

                    ┌────────────────────┐
                    │     MacBook        │
                    │ Built-in Microphone│
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │   Audio Capture    │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Voice / Sound      │
                    │ Activity Detection │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Audio Window       │
                    │ Extraction         │
                    └─────────┬──────────┘
                              │
                              ▼
              ┌───────────────┼────────────────┐
              │               │                │
              ▼               ▼                ▼
        Temporal Features  Spectral       Spatial Features
                          Features
              │               │                │
              └───────────────┼────────────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Feature Vector     │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Direction          │
                    │ Classifier         │
                    └─────────┬──────────┘
                              │
                       ┌──────┴──────┐
                       ▼             ▼
                  Direction      Confidence
                       │             │
                       └──────┬──────┘
                              ▼
                    ┌────────────────────┐
                    │ Spatial UI         │
                    └────────────────────┘

⸻

7. Phase 0 - Audio Hardware Discovery

This phase is mandatory.

Create a diagnostic mode before implementing localization.

The diagnostic screen should display:

Audio Device
------------------------------
Name: Built-in Microphone
Input Channels: 3
Sample Rate: 48000 Hz
Format: Float32
Channel 1: available
Channel 2: available
Channel 3: available
Spatial information:
Unknown / Available / Not available

The actual values must come from Core Audio.

Do not hard-code them.

Diagnostic Requirements

Implement functionality to:

1. Enumerate audio input devices.
2. Identify the default input device.
3. Identify the built-in microphone device.
4. Read its stream format.
5. Determine channel count.
6. Determine sample rate.
7. Determine channel layout if available.
8. Capture a short recording.
9. Save individual available channels when possible.
10. Display waveform information.
11. Display RMS energy for each channel.
12. Determine whether channels are identical, correlated, or independently informative.

If only one useful audio stream is exposed, continue with the single-stream acoustic-fingerprint approach.

Do not block the entire project because independent microphone channels are unavailable.

⸻

8. Phase 1 - Audio Capture

Implement a reusable audio capture service.

Suggested abstraction:

protocol AudioCaptureService {
    func start()
    func stop()
    var audioStream: AsyncStream<AudioFrame> { get }
}

The implementation should:

* capture microphone input in real time
* avoid blocking the UI thread
* use appropriate audio session/device configuration
* provide timestamped audio frames
* preserve sample rate information
* support mono and multichannel input
* handle device changes gracefully
* handle microphone permission errors

The capture layer should be independent of the classifier.

⸻

9. Phase 2 - Voice Activity Detection

The system should not continuously classify silence.

Implement a lightweight Voice Activity Detector.

Initial implementation can use:

* RMS energy
* adaptive noise floor
* short-term energy
* spectral energy
* minimum speech duration

Example pipeline:

Microphone
    ↓
20-30 ms frames
    ↓
RMS
    ↓
Noise-floor estimation
    ↓
Speech threshold
    ↓
Speech detected

The detector should avoid triggering on:

* silence
* very low-level background noise
* short accidental clicks
* keyboard sounds where possible

Do not require perfect speech recognition.

The system only needs to know that a useful sound event is present.

⸻

10. Phase 3 - Audio Windowing

When speech is detected, collect an analysis window.

Initial parameters should be configurable rather than hard-coded.

Example:

Frame size:
20-30 ms
Analysis window:
90-200 ms
Overlap:
50% or configurable

The exact values should be determined experimentally.

The system should allow future tuning without changing the architecture.

⸻

11. Phase 4 - Feature Extraction

Create a dedicated feature extraction module.

Potential features:

Time-domain

* RMS
* peak amplitude
* zero-crossing rate
* temporal envelope
* attack time
* decay characteristics

Frequency-domain

Use FFT/vDSP.

Extract:

* spectral centroid
* spectral bandwidth
* spectral rolloff
* spectral flux
* dominant frequency
* energy by frequency band

Speech-oriented features

Consider:

* log-mel filterbank energies
* MFCCs

Spatial features

If multiple useful channels are available:

* channel energy differences
* cross-correlation
* GCC-PHAT
* TDOA
* inter-channel phase differences

If only one processed channel is available, spatial features should not be fabricated.

The feature extractor must explicitly record which features are available.

⸻

12. GCC-PHAT

If multiple independent audio channels are available, implement GCC-PHAT.

For microphone pair:

Mic A
Mic B

perform:

Audio A ── FFT ──┐
                 │
                 ├── Cross Spectrum
                 │
Audio B ── FFT ──┘
                     ↓
                  PHAT
                     ↓
                 IFFT
                     ↓
              Cross-correlation
                     ↓
                  TDOA

For three channels:

TDOA(A,B)
TDOA(A,C)
TDOA(B,C)

Use these as additional features.

Do not assume that TDOA alone provides reliable 360-degree localization.

⸻

13. Phase 5 - Calibration

Calibration is a core part of this project.

The classifier should be trained/calibrated for the actual:

* MacBook
* room
* surface
* laptop orientation
* typical environment

The calibration workflow should guide the user.

Example:

Place the MacBook in its normal position.
You will be asked to stand at:
1. FRONT
2. FRONT-RIGHT
3. RIGHT
4. REAR-RIGHT
5. REAR
6. REAR-LEFT
7. LEFT
8. FRONT-LEFT

At every position:

Stand approximately 1 meter away.
Speak naturally for 5-10 seconds.
Example:
"Hello, this is a calibration recording."

Collect multiple samples.

Do not rely on one sample per zone.

⸻

14. Calibration Data Format

Store calibration data locally.

Example conceptual structure:

{
  "profile": {
    "device": "MacBook",
    "sampleRate": 48000,
    "channels": 1
  },
  "zones": {
    "front": [],
    "frontRight": [],
    "right": [],
    "rearRight": [],
    "rear": [],
    "rearLeft": [],
    "left": [],
    "frontLeft": []
  }
}

Do not hard-code this exact schema if a better Swift Codable model is appropriate.

Calibration data should be versioned.

⸻

15. Phase 6 - Classifier

Start with a simple interpretable classifier.

Recommended first options:

1. Regularized linear classifier
2. Logistic regression
3. Small nearest-neighbor baseline
4. Small Core ML classifier if necessary

Do not start with a large neural network.

The baseline classifier should establish whether the acoustic features contain enough directional information.

Output:

Direction
Confidence

Example:

Direction: Front-Right
Confidence: 0.87

⸻

16. UNKNOWN / REJECTION CLASS

This is mandatory.

The system must not always choose one of the eight directions.

Example:

Front:       0.41
Front-Right: 0.39
Right:       0.12
Others:      0.08

This should potentially result in:

UNKNOWN

rather than:

FRONT

Implement:

* confidence threshold
* margin between top predictions
* novelty detection where practical
* negative examples

⸻

17. Negative Training Examples

Calibration should collect negative examples.

Examples:

* silence
* keyboard typing
* mouse clicks
* fan noise
* air conditioner
* music
* random room noise
* MacBook speaker output
* speech from outside the intended calibration area

The model should learn:

UNKNOWN

when the signal does not sufficiently resemble a calibrated directional speech event.

⸻

18. Eight-Zone Definition

Use the following initial angular model:

                    FRONT
                      0°
                      ↑
             FRONT-LEFT    FRONT-RIGHT
                315°          45°
LEFT 270° ───────── [MAC] ───────── 90° RIGHT
             REAR-LEFT     REAR-RIGHT
                225°         135°
                      ↓
                    180°
                     REAR

Zone boundaries:

FRONT:
337.5° - 22.5°
FRONT-RIGHT:
22.5° - 67.5°
RIGHT:
67.5° - 112.5°
REAR-RIGHT:
112.5° - 157.5°
REAR:
157.5° - 202.5°
REAR-LEFT:
202.5° - 247.5°
LEFT:
247.5° - 292.5°
FRONT-LEFT:
292.5° - 337.5°

These are logical zones.

Do not claim that the system can produce a physically accurate angle until experimentally validated.

⸻

19. Start With Four Zones

Before attempting eight-way classification, implement:

FRONT
RIGHT
REAR
LEFT

Validate whether the MacBook can reliably distinguish these.

Only proceed to eight zones after measuring performance.

This prevents building a complicated UI around an unreliable localization model.

⸻

20. Phase 7 - Visualization

Build a SwiftUI visualization.

The MacBook should be represented as the center object.

Example:

                    FRONT
                      ▲
                      │
               ┌──────┴──────┐
               │             │
          FRONT-LEFT    FRONT-RIGHT
               │             │
               │   MACBOOK   │
LEFT ──────────┤      💻     ├──────── RIGHT
               │             │
          REAR-LEFT     REAR-RIGHT
               │             │
               └──────┬──────┘
                      │
                      ▼
                     REAR

The detected direction should be visually highlighted.

The UI should also show:

Detected Direction
FRONT-RIGHT
Confidence
87%
Signal
ACTIVE

⸻

21. Sound-Wave Visualization

When speech is detected, show animated sound waves moving from the detected direction toward the MacBook.

For example:

              🔊
             ))))
            )))))
           ))))))
              \
               \
                💻

The visualization is illustrative.

Do not imply that the displayed wave geometry is the actual measured physical waveform unless the underlying calculation supports it.

⸻

22. Real-Time Behavior

The UI should update continuously but should not jump between zones excessively.

Use temporal smoothing.

Example:

Frame 1: FRONT-RIGHT 0.78
Frame 2: FRONT-RIGHT 0.82
Frame 3: FRONT       0.51
Frame 4: FRONT-RIGHT 0.80
Frame 5: FRONT-RIGHT 0.84

The UI should remain:

FRONT-RIGHT

rather than rapidly switching.

Possible approaches:

* exponential moving average
* rolling probability average
* majority vote
* hysteresis

Make the smoothing configurable.

⸻

23. Evaluation Framework

Do not judge the system by visual appearance.

Build a reproducible evaluation tool.

For every test sample store:

Actual zone
Predicted zone
Confidence
Timestamp
Feature vector
Correct / incorrect

Calculate:

Accuracy
Per-zone accuracy
Confusion matrix
Unknown rate
False-positive rate
Confidence distribution

Example:

                  Predicted
             F    FR    R    RR
Actual F     91    6    1     2
       FR     8   82    7     3
       R      1    8   88     3
       RR     2    4    6    88

The actual values must come from experiments.

Never invent performance numbers.

⸻

24. Test Conditions

Evaluate under different conditions.

Distance

Test approximately:

0.5 m
1 m
1.5 m
2 m
3 m

Speaker

Test multiple people if possible.

Speech

Test:

* normal speech
* quiet speech
* loud speech
* different words
* continuous speech
* short phrases

Environment

Test:

* quiet room
* moderate background noise
* fan running
* air conditioning
* music
* reflective room

Laptop position

Test:

* centered
* slightly rotated
* different surfaces

The calibration-dependent nature of the system should be clearly documented.

⸻

25. Optional Active Acoustic Sensing

After passive localization works, investigate an optional active sensing mode inspired by Holo.

Potential architecture:

MacBook Speaker
       ↓
 Short Chirp
       ↓
 Room / Environment
       ↓
 Microphone
       ↓
 Acoustic Response
       ↓
 Additional Features
       ↓
 Direction Classifier

This should be an experimental feature.

Do not assume that active acoustic sensing will improve speech direction classification.

Measure whether it actually provides useful information.

Potential concerns:

* human audibility
* speaker frequency response
* microphone frequency response
* room reflections
* system audio processing
* user experience
* privacy
* interference with speech

Keep it disabled by default until validated.

⸻

26. Privacy Requirements

All processing should preferably happen locally.

The application should not:

* upload microphone recordings
* send speech to cloud APIs
* perform cloud transcription
* retain raw recordings unless explicitly requested for calibration/debugging

Calibration recordings should be stored locally and clearly disclosed.

Provide a way to delete calibration data.

⸻

27. Suggested Project Structure

Use a modular structure similar in spirit to Holo.

Example:

MacSoundLocator/
│
├── App/
│   ├── MacSoundLocatorApp.swift
│   └── AppState.swift
│
├── Audio/
│   ├── AudioCaptureService.swift
│   ├── AudioDeviceInspector.swift
│   ├── AudioFrame.swift
│   └── MicrophonePermission.swift
│
├── Detection/
│   ├── VoiceActivityDetector.swift
│   └── SoundEventDetector.swift
│
├── DSP/
│   ├── FFTProcessor.swift
│   ├── FeatureExtractor.swift
│   ├── GCCPHAT.swift
│   ├── CrossCorrelation.swift
│   └── SpectralFeatures.swift
│
├── Localization/
│   ├── Direction.swift
│   ├── DirectionClassifier.swift
│   ├── ConfidenceEstimator.swift
│   ├── TemporalSmoother.swift
│   └── RejectionDetector.swift
│
├── Calibration/
│   ├── CalibrationManager.swift
│   ├── CalibrationSession.swift
│   ├── CalibrationSample.swift
│   └── CalibrationProfile.swift
│
├── ML/
│   ├── FeatureVector.swift
│   ├── ModelTrainer.swift
│   └── ModelRunner.swift
│
├── Visualization/
│   ├── SpatialFieldView.swift
│   ├── MacBookView.swift
│   ├── SoundWaveView.swift
│   └── DirectionIndicator.swift
│
├── Diagnostics/
│   ├── AudioDiagnosticsView.swift
│   ├── RecordingView.swift
│   └── EvaluationRunner.swift
│
└── Tests/
    ├── DSPTests/
    ├── ClassifierTests/
    ├── CalibrationTests/
    └── AudioTests/

The exact structure may be adjusted if the implementation benefits from a different architecture.

⸻

28. Development Order

Do not attempt the entire system at once.

Implement in this order:

STEP 1
Audio device discovery
        ↓
STEP 2
Microphone permission + capture
        ↓
STEP 3
Diagnostic recording
        ↓
STEP 4
Determine actual available channel information
        ↓
STEP 5
Voice activity detection
        ↓
STEP 6
Feature extraction
        ↓
STEP 7
Four-zone calibration
        ↓
STEP 8
Baseline classifier
        ↓
STEP 9
Four-zone evaluation
        ↓
STEP 10
Eight-zone calibration
        ↓
STEP 11
Eight-zone classifier
        ↓
STEP 12
Confidence + UNKNOWN rejection
        ↓
STEP 13
Temporal smoothing
        ↓
STEP 14
Spatial visualization
        ↓
STEP 15
Optional GCC-PHAT if useful multichannel data exists
        ↓
STEP 16
Optional active acoustic sensing

⸻

29. Engineering Principles

Do not assume

Never assume:

* number of microphones
* microphone positions
* independent microphone channels
* exact microphone geometry
* availability of raw microphone signals
* exact direction accuracy
* distance estimation
* beamforming behavior

Verify through Core Audio and experiments.

Measure before optimizing

Every major algorithmic decision should be supported by measured data.

Keep DSP independent of UI

The localization engine must be testable without SwiftUI.

Keep calibration separate from inference

Calibration generates a profile.

Inference consumes the profile.

Make parameters configurable

Avoid magic numbers.

Provide diagnostics

The application should make it easy to understand why localization is failing.

⸻

30. First Deliverable

The first Codex milestone should not be the complete localization application.

Build:

Mac Audio Diagnostic

It should:

1. Request microphone permission.
2. Enumerate the available input devices.
3. Identify the built-in microphone.
4. Report channel count.
5. Report sample rate.
6. Report audio format.
7. Capture a short sample.
8. Display real-time RMS.
9. Display waveform.
10. Record available channels separately if possible.
11. Display channel correlation.
12. Save a diagnostic report.

Example UI:

┌────────────────────────────────────────┐
│       MAC AUDIO DIAGNOSTIC             │
├────────────────────────────────────────┤
│ Device                                 │
│ Built-in Microphone                    │
│                                        │
│ Channels: 3                            │
│ Sample Rate: 48,000 Hz                 │
│ Format: Float32                        │
│                                        │
│ Channel 1       RMS: 0.023             │
│ Channel 2       RMS: 0.021             │
│ Channel 3       RMS: 0.024             │
│                                        │
│ Correlation                            │
│ CH1 ↔ CH2: 0.91                        │
│ CH1 ↔ CH3: 0.84                        │
│ CH2 ↔ CH3: 0.88                        │
│                                        │
│ [ Start Recording ]                    │
└────────────────────────────────────────┘

Do not fabricate these values. They are examples only.

⸻

31. Definition of Done for Phase 1

Phase 1 is complete when:

* the application builds successfully on Apple Silicon
* microphone permission works
* the built-in microphone is detected
* actual channel count is reported
* actual sample rate is reported
* real-time audio is captured
* waveform is displayed
* RMS is displayed
* recording works
* channel information is logged
* no unsupported assumptions are made about microphone geometry

Only after this phase should localization development begin.

⸻

32. Important Research References

Primary reference:

Holo:
https://github.com/JustinGamer191/Holo

Apple MacBook Air specifications:
https://www.apple.com/in/macbook-air/specs/

Apple AVFAudio documentation:
https://developer.apple.com/documentation/avfaudio/

Apple AVAudioEngine:
https://developer.apple.com/documentation/avfaudio/avaudioengine

Apple Core Audio documentation:
https://developer.apple.com/documentation/coreaudio

These sources should be treated as references, not as proof that a particular MacBook exposes a specific microphone topology.

⸻

33. Final Product Vision

The final application should feel like a spatial awareness layer around the MacBook.

When somebody speaks:

                    🔊
                 "Hello"
                    ↓
                 ))))))
                )))))))
                   \
                    \
                     💻

the MacBook should visually determine:

┌──────────────────────────────────┐
│       SOUND SOURCE DETECTED      │
│                                  │
│             FRONT                │
│               ▲                  │
│          ╲    │    🔊            │
│           ╲   │   ))             │
│            ╲  │  )))             │
│ LEFT ─────── 💻 ───────── RIGHT │
│               │                  │
│               ▼                  │
│              REAR                │
│                                  │
│ Direction: FRONT-RIGHT           │
│ Confidence: 87%                  │
└──────────────────────────────────┘

The application should be honest about uncertainty.

If the signal is ambiguous:

Direction: UNKNOWN
Confidence: LOW

is preferable to confidently displaying the wrong direction.

The project should prioritize measured feasibility, reproducible experiments, calibration, and accuracy over visual complexity.

⸻

34. Codex Instructions

When starting implementation:

1. Read this specification completely.
2. Inspect the Holo repository architecture.
3. Do not immediately implement the classifier.
4. First implement the Mac audio diagnostic.
5. Run the application on the actual MacBook.
6. Record and inspect the available microphone channels.
7. Determine what spatial information is actually accessible.
8. Based on those measurements, choose between:
    * multichannel TDOA/GCC-PHAT
    * single/processed-channel acoustic fingerprinting
    * hybrid DSP + ML
9. Document the decision and evidence.
10. Implement a four-zone proof of concept.
11. Measure accuracy.
12. Only then expand to eight zones.

Do not claim that the system can localize speech accurately until it has been tested on real recordings.

The guiding principle is:

Discover the actual MacBook audio capabilities first, then design the localization algorithm around the information macOS actually provides.