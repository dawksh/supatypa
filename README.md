# SupaTypa

A macOS menu bar app that tracks your daily typing statistics (characters and words typed).

## Features

- **Real-time tracking**: Monitors keyboard input system-wide
- **Daily statistics**: Tracks characters and words typed per day
- **Auto-reset**: Statistics reset automatically at midnight
- **Menu bar integration**: Displays stats in the macOS menu bar
- **Lightweight**: Minimal resource usage, runs in the background

## Requirements

- macOS (requires Accessibility permissions)
- Xcode 14.0 or later

## Installation

1. Clone the repository
2. Open `supatypa.xcodeproj` in Xcode
3. Build and run the project

## Setup

On first launch, the app will request Accessibility permissions. This is required to monitor keyboard events.

1. Grant Accessibility permissions when prompted
2. If the prompt doesn't appear, go to **System Settings > Privacy & Security > Accessibility**
3. Enable the app in the list

## Usage

Once running, the app appears in your menu bar with a ⌨️ icon. Click it to view:

- Today's character count
- Today's word count

The statistics update every 2 seconds and reset automatically at midnight.

## Architecture

- `KeyboardMonitor`: Monitors keyboard events using CGEvent taps
- `StatsStore`: Manages persistent storage of statistics using UserDefaults
- `StatusBarController`: Handles menu bar UI and display updates
- `AppDelegate`: Manages app lifecycle and permission checks

## Privacy

The app only tracks typing statistics locally. No data is transmitted or stored outside your device. Keyboard events are processed in real-time and only character/word counts are stored.
