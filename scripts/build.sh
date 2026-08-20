#!/usr/bin/env bash
set -euo pipefail

echo "[SonicField] Building native macOS application and test suite..."

mkdir -p bin scratch

# Create VFS overlay to bypass duplicate system modulemap conflict in CommandLineTools
cat << 'EOF' > scratch/vfs.yaml
version: 0
case-sensitive: false
roots:
  - name: "/Library/Developer/CommandLineTools/usr/include/swift/module.modulemap"
    type: "file"
    external-contents: "/dev/null"
EOF

SDK_PATH=$(xcrun --show-sdk-path)
TARGET="arm64-apple-macosx14.0"

# 1. Compile SonicField App Executable
swiftc -sdk "$SDK_PATH" \
  -target "$TARGET" \
  -vfsoverlay scratch/vfs.yaml \
  -parse-as-library \
  Sources/SonicFieldKit/Audio/*.swift \
  Sources/SonicFieldKit/Diagnostics/*.swift \
  Sources/SonicFieldKit/DSP/*.swift \
  Sources/SonicFieldKit/Detection/*.swift \
  Sources/SonicFieldKit/Localization/*.swift \
  Sources/SonicFieldKit/Calibration/*.swift \
  Sources/SonicFieldKit/Actions/*.swift \
  Sources/SonicFieldKit/Evaluation/*.swift \
  Sources/SonicFieldKit/App/*.swift \
  Sources/SonicFieldKit/Visualization/*.swift \
  Sources/SonicFieldApp/main.swift \
  -o bin/SonicField

echo "[SonicField] Built executable: bin/SonicField"

# 2. Compile Test Runner Executable
swiftc -sdk "$SDK_PATH" \
  -target "$TARGET" \
  -vfsoverlay scratch/vfs.yaml \
  Sources/SonicFieldKit/Audio/AudioFrame.swift \
  Sources/SonicFieldKit/Audio/MicrophonePermission.swift \
  Sources/SonicFieldKit/Audio/AudioDeviceInspector.swift \
  Sources/SonicFieldKit/Audio/AudioCaptureService.swift \
  Sources/SonicFieldKit/Diagnostics/ChannelCorrelation.swift \
  Sources/SonicFieldKit/Diagnostics/DiagnosticReportGenerator.swift \
  Sources/SonicFieldKit/DSP/FFTProcessor.swift \
  Sources/SonicFieldKit/DSP/FeatureExtractor.swift \
  Sources/SonicFieldKit/DSP/GCCPHAT.swift \
  Sources/SonicFieldKit/Detection/VoiceActivityDetector.swift \
  Sources/SonicFieldKit/Detection/TapDetector.swift \
  Sources/SonicFieldKit/Localization/Direction.swift \
  Sources/SonicFieldKit/Localization/DirectionClassifier.swift \
  Sources/SonicFieldKit/Localization/TemporalSmoother.swift \
  Sources/SonicFieldKit/Calibration/CalibrationProfile.swift \
  Sources/SonicFieldKit/Calibration/CalibrationManager.swift \
  Sources/SonicFieldKit/Actions/TriggerAction.swift \
  Sources/SonicFieldKit/Actions/ActionManager.swift \
  Sources/SonicFieldKit/Evaluation/EvaluationRunner.swift \
  Tests/SonicFieldTests/*.swift \
  -o bin/SonicFieldTests

echo "[SonicField] Built test runner: bin/SonicFieldTests"
