# How to Run Aha! Catcher

## Quick Answer

**For microphone access, YES - you need a local server.** Modern browsers block microphone access for `file://` URLs for security reasons.

## Option 1: Use a Local Server (Recommended) ✅

### Using Python (Easiest)

**Python 3:**
```bash
python3 -m http.server 8000
```

**Python 2:**
```bash
python -m SimpleHTTPServer 8000
```

Then open: **http://localhost:8000**

### Using Node.js

**If you have Node.js installed:**
```bash
npx http-server -p 8000
```

Then open: **http://localhost:8000**

### Using PHP

**If you have PHP installed:**
```bash
php -S localhost:8000
```

Then open: **http://localhost:8000**

## Option 2: Open Directly (May Not Work) ⚠️

You can try opening `index.html` directly:
- Double-click the file, or
- Right-click → "Open with" → Browser

**However**, this may fail because:
- ❌ Browsers block microphone access for `file://` URLs
- ❌ You'll see an error: "getUserMedia is not supported"
- ❌ The app won't be able to record audio

## Why You Need a Server

Modern browsers have security restrictions:
- **Microphone API** (`getUserMedia`) requires HTTPS or `localhost`
- **File protocol** (`file://`) is considered insecure
- **Local server** (`localhost:8000`) is considered secure

## Step-by-Step: Running the Server

1. **Open Terminal** (or Command Prompt)

2. **Navigate to the project folder:**
   ```bash
   cd /Users/shipeifeng/Mini-projects123
   ```

3. **Start the server:**
   ```bash
   python3 -m http.server 8000
   ```
   
   You should see:
   ```
   Serving HTTP on :: port 8000 (http://[::]:8000/) ...
   ```

4. **Open your browser** and go to:
   ```
   http://localhost:8000
   ```

5. **Click on `index.html`** in the file listing

6. **Grant microphone permission** when prompted

7. **Click "Capture Aha!"** to test!

## Troubleshooting

### "Port 8000 already in use"

Use a different port:
```bash
python3 -m http.server 8080
```
Then open: `http://localhost:8080`

### "python3: command not found"

Try:
```bash
python -m http.server 8000
```

### "Permission denied"

Make sure you're in the correct directory:
```bash
cd /Users/shipeifeng/Mini-projects123
ls index.html  # Should show the file
```

### Microphone still not working

1. Check browser permissions:
   - Chrome: Settings → Privacy → Site Settings → Microphone
   - Firefox: Preferences → Privacy → Permissions → Microphone
   - Safari: Preferences → Websites → Microphone

2. Make sure you're using `http://localhost:8000` (not `file://`)

3. Try a different browser

## Quick Start Script

Create a file called `start-server.sh`:

```bash
#!/bin/bash
cd "$(dirname "$0")"
python3 -m http.server 8000
```

Make it executable:
```bash
chmod +x start-server.sh
```

Then just run:
```bash
./start-server.sh
```

## Summary

✅ **Use a local server** - Required for microphone access
✅ **Easiest method**: `python3 -m http.server 8000`
✅ **Then visit**: `http://localhost:8000`
✅ **Click**: `index.html` in the file listing

Your app will work perfectly once you're accessing it via `localhost`!

