# CORS Error Fix

## Understanding the Errors

### 1. CORS Error (Main Issue)
```
Access to fetch at 'https://space.ai-builders.com/backend/v1/audio/transcriptions' 
from origin 'http://localhost:8000' has been blocked by CORS policy
```

**What it means:**
- Browsers block requests from one origin (localhost:8000) to another (space.ai-builders.com)
- This is a security feature called CORS (Cross-Origin Resource Sharing)
- The API server needs to explicitly allow your origin, but it doesn't

**Solution:** Use a backend proxy server

### 2. ScriptProcessorNode Deprecation Warning
```
[Deprecation] The ScriptProcessorNode is deprecated. Use AudioWorkletNode instead.
```

**What it means:**
- The Web Audio API method we're using is deprecated
- It still works, but browsers recommend using AudioWorkletNode instead
- **Not critical** - the app will still function

**Solution:** Can be updated later for better performance

### 3. Favicon 404 Error
```
Failed to load resource: the server responded with a status of 404 (File not found)
```

**What it means:**
- Browser is looking for a favicon (website icon)
- Not found, but doesn't affect functionality
- **Not critical** - just a missing icon file

**Solution:** Can add a favicon later if desired

## The Fix: Backend Proxy Server

Since the API doesn't allow CORS from localhost, we need a backend proxy that:
1. Runs on the same origin as your frontend (no CORS issue)
2. Makes API calls server-side (where CORS doesn't apply)
3. Returns results to your frontend

## Setup Instructions

### Step 1: Install Node.js Dependencies

```bash
npm install
```

This will install:
- `express` - Web server framework
- `cors` - CORS middleware
- `multer` - File upload handling
- `node-fetch` - HTTP client
- `form-data` - Form data handling

### Step 2: Start the Proxy Server

```bash
node server.js
```

Or with auto-reload:
```bash
npm run dev
```

You should see:
```
🚀 Proxy server running on http://localhost:3000
📁 Serving files from: /path/to/project
🔗 API Base URL: https://space.ai-builders.com/backend
✅ Open http://localhost:3000 in your browser
```

### Step 3: Use the New URL

Instead of `http://localhost:8000`, use:
```
http://localhost:3000
```

The proxy server will:
- Serve your `index.html` file
- Handle API calls through `/api/transcribe` and `/api/chat`
- Avoid CORS issues completely

## How It Works

### Before (Direct API Call - CORS Error)
```
Browser (localhost:8000) 
  → ❌ API (space.ai-builders.com) 
  → CORS BLOCKED
```

### After (Proxy Server - No CORS)
```
Browser (localhost:3000) 
  → ✅ Proxy Server (localhost:3000/api/transcribe)
  → ✅ API (space.ai-builders.com)
  → ✅ Response back to browser
```

## Architecture

```
┌─────────────┐
│   Browser   │
│  (Frontend) │
└──────┬──────┘
       │ HTTP Request
       ▼
┌─────────────┐
│ Proxy Server│  ← Same origin, no CORS!
│ (localhost) │
└──────┬──────┘
       │ API Request
       ▼
┌─────────────┐
│  AI Builder │
│     API     │
└─────────────┘
```

## Troubleshooting

### Port 3000 already in use?
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill

# Or use a different port
# Edit server.js and change PORT = 3000 to PORT = 3001
```

### npm install fails?
Make sure you have Node.js installed:
```bash
node --version  # Should show v14 or higher
npm --version   # Should show v6 or higher
```

### Still getting CORS errors?
1. Make sure you're using `http://localhost:3000` (not 8000)
2. Make sure the proxy server is running (`node server.js`)
3. Check browser console for specific error messages

## Summary

✅ **Fixed:** CORS error by using backend proxy
⚠️ **Warning:** ScriptProcessorNode deprecation (non-critical)
⚠️ **Warning:** Missing favicon (non-critical)

Your app should now work perfectly!

