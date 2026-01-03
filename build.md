# Build & Release Guide for Supatypa

This guide covers the complete process for building and releasing new versions of Supatypa for Homebrew distribution.

## Prerequisites

- Xcode installed and configured
- GitHub repository: `dawksh/supatypa`
- Homebrew tap repository: `dawksh/homebrew-supatypa`
- No Apple Developer account required (uses ad-hoc signing)

## Build Steps

### 1. Build the Release Binary

```bash
cd /Users/daksh/projects/supatypa/supatypa
xcodebuild -project supatypa.xcodeproj -scheme supatypa -configuration Release clean build
```

Build output will be in: `build/Build/Products/Release/`

### 2. Extract the Executable Binary

```bash
cd build/Build/Products/Release
cp supatypa.app/Contents/MacOS/supatypa supatypa
```

This extracts the executable from the .app bundle.

### 3. Verify the Binary Runs

```bash
./supatypa
```

**Expected Result:**

- Menu bar icon appears (⌨️)
- App runs in background
- No Dock icon
- Can quit via menu bar

If this fails, stop and debug before proceeding.

### 4. Ad-hoc Sign the Binary

Sign the binary (no Apple Developer account needed):

```bash
codesign --force --deep --sign - supatypa
```

**Verify signature:**

```bash
codesign -vv supatypa
```

Expected output should include:

```
valid on disk
```

### 5. Generate SHA256 Hash

Generate the SHA256 hash for the Homebrew formula:

```bash
shasum -a 256 supatypa
```

**Save this hash** - you'll need it for the Homebrew formula.

Example output:

```
abc123def456... supatypa
```

### 6. Update Version Number

Update the version in:

- `supatypa.xcodeproj/project.pbxproj` (MARKETING_VERSION)
- Or via Xcode: Target → General → Version

Recommended format: `MAJOR.MINOR.PATCH` (e.g., `0.1.0`, `0.2.0`, `1.0.0`)

### 7. Create GitHub Release

#### 7.1. Tag the Release

```bash
cd /Users/daksh/projects/supatypa/supatypa
git tag 0.1.0  # Replace with actual version
git push --tags
```

#### 7.2. Create GitHub Release

1. Go to: https://github.com/dawksh/supatypa/releases/new
2. Select the tag you just created (e.g., `0.1.0`)
3. Release title: `0.1.0` (or add release notes)
4. Upload the `supatypa` binary as an asset
5. Publish the release

**Important:** Only upload the `supatypa` binary file, not the .app bundle.

### 8. Update Homebrew Formula

#### 8.0. Check homebrew tap

```bash
cd ../homebrew-supatypa
```

If no tap then move to 8.1 else 8.2

#### 8.1. Clone the Homebrew Tap (if not already)

```bash
git clone https://github.com/dawksh/homebrew-supatypa.git
cd homebrew-supatypa
```

#### 8.2. Edit the Formula

Edit `Formula/supatypa.rb`:

```ruby
class Supatypa < Formula
  desc "macOS menu bar app that tracks daily typing statistics"
  homepage "https://github.com/dawksh/supatypa"
  url "https://github.com/dawksh/supatypa/releases/download/v0.1.0/supatypa"
  sha256 "<PASTE_SHA256_HERE>"
  license "MIT"

  depends_on :macos

  def install
    bin.install "supatypa"
  end

  def caveats
    <<~EOS
      Supatypa runs as a background menu bar app.

      Input Monitoring permission is REQUIRED:
        System Settings → Privacy & Security → Input Monitoring
        Enable "supatypa"

      If macOS blocks the app on first launch:
        System Settings → Privacy & Security → Allow Anyway

      Supatypa only stores typing COUNTS, never text.
    EOS
  end
end
```

**Update:**

- `url`: Change version in the URL (e.g., `v0.1.0` → `v0.2.0`)
- `sha256`: Paste the SHA256 hash from Step 5

#### 8.3. Test the Formula Locally

```bash
brew install --build-from-source Formula/supatypa.rb
```

Or test with the URL directly:

```bash
brew install --formula --build-from-source https://raw.githubusercontent.com/dawksh/homebrew-supatypa/main/Formula/supatypa.rb
```

#### 8.4. Commit and Push

```bash
git add Formula/supatypa.rb
git commit -m "Update supatypa to v0.1.0"
git push
```

### 9. Verify Installation

Test the installation from the tap:

```bash
brew tap dawksh/supatypa
brew install supatypa
supatypa
```

**First Run:**

- macOS may block the app - click "Allow Anyway" in System Settings
- Grant Accessibility permission when prompted
- Menu bar icon should appear

### 10. Release Checklist

- [ ] Built Release configuration in Xcode
- [ ] Extracted binary from .app bundle
- [ ] Verified binary runs correctly
- [ ] Ad-hoc signed the binary
- [ ] Generated SHA256 hash
- [ ] Updated version number in project
- [ ] Created and pushed Git tag
- [ ] Created GitHub release with binary asset
- [ ] Updated Homebrew formula (version + SHA256)
- [ ] Tested formula locally
- [ ] Committed and pushed formula changes
- [ ] Verified installation via Homebrew

## Troubleshooting

### Binary Won't Run

- Check Console.app for crash logs
- Verify Input Monitoring permissions
- Ensure you're running on macOS (not iOS simulator)
- Check if binary architecture matches your Mac (arm64 vs x86_64)

### Codesign Fails

```bash
codesign --force --deep --sign - supatypa
```

If `--deep` fails, try without it:

```bash
codesign --force --sign - supatypa
```

### Homebrew Install Fails

- Verify the GitHub release URL is correct
- Check SHA256 hash matches the uploaded binary
- Ensure the binary filename matches exactly: `supatypa`
- Test the download URL in a browser

### Gatekeeper Blocks App

Users need to:

1. Go to System Settings → Privacy & Security
2. Click "Allow Anyway" for the blocked app
3. Grant Input Monitoring permission

## Notes

- **No Apple Developer Account Required**: Ad-hoc signing works fine for Homebrew distribution
- **No Notarization**: Not required for Homebrew formula distribution
- **Binary Only**: We distribute the executable, not the .app bundle
- **Versioning**: Use semantic versioning (MAJOR.MINOR.PATCH)
