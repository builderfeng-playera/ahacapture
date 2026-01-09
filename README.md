# Aha! Catcher 🎯

Capture fleeting ideas and moments of curiosity with zero friction.

## Features

- ✅ Continuous 30-second audio buffer
- ✅ One-click capture
- ✅ Automatic transcription
- ✅ AI-powered research summary
- ✅ Clean, modern UI

## Quick Start

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the server:**
   ```bash
   node server.js
   ```

3. **Open in browser:**
   ```
   http://localhost:3001
   ```

### Deploy to Vercel

See [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md) for detailed instructions.

**Quick deploy:**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Add environment variable
vercel env add API_KEY

# Production deploy
vercel --prod
```

## Project Structure

```
├── api/
│   ├── transcribe.js    # Serverless function for transcription
│   └── chat.js          # Serverless function for research summary
├── index.html           # Main frontend app
├── server.js            # Local development server
├── package.json         # Dependencies
├── vercel.json          # Vercel configuration
└── README.md            # This file
```

## Environment Variables

- `API_KEY` - Your AI Builder API key (required for production)

## How It Works

1. **Continuous Recording**: The app maintains a 30-second circular buffer of audio
2. **Capture**: Click "Capture Aha!" to extract the last 30 seconds
3. **Transcription**: Audio is sent to AI Builder API for transcription
4. **Research**: Transcription is analyzed to generate a research summary
5. **Display**: Both transcription and summary are shown

## Technology Stack

- **Frontend**: HTML, CSS, JavaScript (Web Audio API)
- **Backend**: Node.js serverless functions (Vercel)
- **API**: AI Builder Platform (transcription + chat completions)

## License

MIT
