# watchOS Hand Gesture Detection Research

## Executive Summary

**Key Finding:** watchOS does **not** provide a public developer API for directly detecting hand gestures (pinch, clench, double tap) programmatically within your app code.

## Available Options

### 1. AssistiveTouch (User-Configurable, Not Programmatic)

**What it is:** A system-level accessibility feature introduced in watchOS 8 that allows users to control their Apple Watch using hand gestures.

**Available Gestures:**
- **Pinch**: Tap index finger to thumb
- **Double Pinch**: Tap index finger to thumb twice quickly
- **Clench**: Make a loose fist
- **Double Clench**: Make a loose fist twice quickly

**Limitations:**
- These gestures are user-configurable in Settings, not developer-controllable
- Users must manually assign a gesture to trigger your app via Siri Shortcuts
- Your app cannot detect these gestures directly in code
- Requires AssistiveTouch to be enabled by the user

**How it works:**
1. User enables AssistiveTouch in Settings > Accessibility
2. User assigns a gesture (e.g., Double Clench) to "Run Shortcut"
3. User selects your app's Siri Shortcut
4. When gesture is performed, system runs the shortcut, which can launch your app

### 2. Double Tap Gesture (watchOS 10, System-Level Only)

**What it is:** A system gesture introduced in watchOS 10 for Apple Watch Series 9 and Ultra 2.

**Limitations:**
- No public developer API available
- Primarily used for system actions (answering calls, stopping timers, etc.)
- Cannot be customized or detected by third-party apps

### 3. Alternative Approaches

**CoreMotion API:**
- Can detect motion and acceleration
- Would require custom ML models or signal processing to detect specific gestures
- High battery consumption
- Not ideal for the "zero friction" requirement

**Button/Crown Interactions:**
- Can detect button presses and Digital Crown rotations
- Requires physical interaction (not a hand gesture)
- Defeats the purpose of gesture-based capture

## Recommended Solution for MVP

Given the constraints, the most viable approach for your MVP is:

**AssistiveTouch + Siri Shortcuts + App Intents**

This allows users to:
1. Perform a simple gesture (Double Clench recommended)
2. System triggers a Siri Shortcut
3. Shortcut launches your app via App Intent
4. Your app immediately begins capturing audio

**Trade-offs:**
- ✅ Single gesture trigger (after initial setup)
- ✅ Minimal friction once configured
- ❌ Requires user to enable AssistiveTouch
- ❌ Requires user to configure gesture assignment
- ❌ Not completely invisible (user must know gesture is configured)

## Code Implementation

See `AhaCatcherApp.swift` for a minimal implementation that can be triggered via Siri Shortcuts.

