# Aha! Catcher - Web MVP Setup Guide

## Overview

This is a web-based MVP for Aha! Catcher that:
1. Continuously records audio from your microphone into a 30-second circular buffer
2. When you click "Capture Aha!", it sends the last 30 seconds to the AI Builder API
3. Displays the transcription and research summary

## Setup Instructions

### 1. Get Your API Key

1. Log in to the AI Builder Student Portal
2. Navigate to the "Commanding AI with the platform's offering" section
3. Find your API key (it should be displayed there)
4. Copy the API key

### 2. Configure the API Key

1. Open `index.html` in a text editor
2. Find this line near the top of the `<script>` section:
   ```javascript
   const API_KEY = 'YOUR_API_KEY_HERE';
   ```
3. Replace `'YOUR_API_KEY_HERE'` with your actual API key:
   ```javascript
   const API_KEY = 'your-actual-api-key-here';
   ```

### 3. Run the Application

**Option A: Open directly in browser**
- Simply double-click `index.html` or open it in your web browser
- Note: Some browsers may block microphone access for `file://` URLs. If this happens, use Option B.

**Option B: Use a local web server (Recommended)**

Using Python:
```bash
# Python 3
python3 -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

Then open: `http://localhost:8000`

Using Node.js (http-server):
```bash
npx http-server -p 8000
```

Then open: `http://localhost:8000`

### 4. Grant Microphone Permissions

When you first open the page, your browser will ask for microphone permission. Click "Allow" to enable audio recording.

## How It Works

1. **Continuous Recording**: The page starts recording audio as soon as you grant microphone permission. It maintains a circular buffer of the last 30 seconds.

2. **Capture**: Click the "Capture Aha!" button to:
   - Extract the last 30 seconds from the buffer
   - Convert it to WAV format
   - Send it to the transcription API
   - Generate a research summary using the supermind-agent-v1 model

3. **Results**: The transcription and research summary are displayed below the button.

## Features

- ✅ Continuous 30-second audio buffer
- ✅ One-click capture
- ✅ Automatic transcription
- ✅ AI-powered research summary
- ✅ Clean, modern UI
- ✅ Responsive design

## API Endpoints Used

1. **`/v1/audio/transcriptions`**: Transcribes audio to text
2. **`/v1/chat/completions`**: Generates research summary using the supermind-agent-v1 model with web search capabilities

## Troubleshooting

### Microphone not working
- Check browser permissions (Settings > Privacy > Microphone)
- Make sure you're using HTTPS or localhost (not `file://`)
- Try a different browser

### API errors
- Verify your API key is correct
- Check that you have API access in the Student Portal
- Check browser console for detailed error messages

### No audio captured
- Make sure you've been recording for at least a few seconds before clicking capture
- Check that your microphone is working in other applications
- Try refreshing the page and granting permissions again

## Technical Details

- **Audio Format**: 44.1kHz, 16-bit PCM, Mono, WAV
- **Buffer Size**: 30 seconds × 44,100 samples/second = 1,323,000 samples
- **Circular Buffer**: Continuously overwrites oldest samples with newest

## Next Steps

After testing the MVP, you can:
1. Deploy it to a web server
2. Add error handling and retry logic
3. Add audio visualization
4. Implement offline queuing
5. Add user authentication
6. Store capture history

