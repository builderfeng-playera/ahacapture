# Fixing Vercel Function Timeout

## Problem

Your Vercel serverless function is timing out with `FUNCTION_INVOCATION_TIMEOUT`. This happens because:

1. **Vercel Free Tier Limit**: 10 seconds maximum execution time
2. **Transcription Takes Time**: Audio transcription can take 15-30+ seconds for 30-second audio clips
3. **Function Exceeds Limit**: Your function is hitting the 10-second timeout

## Solutions

### Solution 1: Upgrade to Vercel Pro (Recommended for Production)

**Vercel Pro Plan** ($20/month) allows:
- Up to **60 seconds** execution time
- Better performance
- More bandwidth

**Steps:**
1. Go to Vercel Dashboard → Settings → Billing
2. Upgrade to Pro plan
3. The `maxDuration: 60` in `vercel.json` will then work

### Solution 2: Optimize Audio Size (Quick Fix)

Reduce the audio duration to stay under 10 seconds:

**Option A: Reduce buffer duration**
```javascript
// In index.html, change:
const BUFFER_DURATION = 10; // Instead of 30 seconds
```

**Option B: Compress audio before sending**
- Add audio compression in the frontend
- Send smaller file = faster transcription

### Solution 3: Use Async Processing Pattern

Instead of waiting for transcription, return immediately and poll for results:

1. **Submit job** → Return job ID immediately (< 1 second)
2. **Poll status** → Check if transcription is ready
3. **Get results** → Fetch when ready

This requires backend changes and a job queue system.

### Solution 4: Use Different API Endpoint

Some APIs support streaming or faster endpoints. Check if AI Builder API has:
- Faster transcription models
- Streaming responses
- Async job endpoints

## Current Fix Applied

I've updated `vercel.json` to set `maxDuration: 60` for the transcription function. However, **this only works on Vercel Pro plan**.

On the free tier, you're limited to 10 seconds.

## Immediate Workaround

### Reduce Audio Duration

Edit `index.html` and change:

```javascript
// Line ~72
const BUFFER_DURATION = 10; // Change from 30 to 10 seconds
```

This will:
- ✅ Keep you under 10-second timeout
- ✅ Still capture your "Aha!" moment
- ✅ Work on free tier

### Test with Shorter Audio

1. Record for only 5-10 seconds
2. Click "Capture Aha!"
3. Should complete within timeout

## Error Handling Improved

I've also improved error handling to:
- Show clearer timeout messages
- Handle API errors better
- Provide user-friendly error messages

## Recommended Path Forward

1. **Short term**: Reduce `BUFFER_DURATION` to 10 seconds
2. **Medium term**: Upgrade to Vercel Pro for 60-second timeout
3. **Long term**: Implement async processing pattern

## Testing

After making changes:

1. **Commit and push**:
   ```bash
   git add .
   git commit -m "Fix timeout: increase maxDuration and improve error handling"
   git push
   ```

2. **Vercel will auto-deploy** (if connected to GitHub)

3. **Test again** with shorter audio clips

## Cost Comparison

- **Free Tier**: 10s timeout, $0/month
- **Pro Tier**: 60s timeout, $20/month
- **Enterprise**: Custom limits, custom pricing

For MVP/testing, free tier with 10-second clips works fine!

