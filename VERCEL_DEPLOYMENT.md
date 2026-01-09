# Deploying Aha! Catcher to Vercel

## Quick Deploy

### Option 1: Deploy via Vercel CLI (Recommended)

1. **Install Vercel CLI** (if not already installed):
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Deploy**:
   ```bash
   vercel
   ```
   
   Follow the prompts:
   - Link to existing project? **No** (first time)
   - Project name: **aha-catcher** (or your choice)
   - Directory: **.** (current directory)
   - Override settings? **No**

4. **Set Environment Variable**:
   ```bash
   vercel env add API_KEY
   ```
   
   When prompted:
   - Value: `sk_e5ec71d9_a491add896e4e94da35be769927505a579f8`
   - Environment: Select **Production**, **Preview**, and **Development**

5. **Redeploy** (to apply environment variable):
   ```bash
   vercel --prod
   ```

### Option 2: Deploy via Vercel Dashboard

1. **Push to GitHub** (if not already):
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Go to Vercel Dashboard**:
   - Visit: https://vercel.com
   - Click "Add New Project"
   - Import your GitHub repository

3. **Configure Project**:
   - Framework Preset: **Other**
   - Root Directory: **.** (leave as is)
   - Build Command: (leave empty)
   - Output Directory: **.** (leave as is)

4. **Add Environment Variable**:
   - Go to Project Settings → Environment Variables
   - Add: `API_KEY` = `sk_e5ec71d9_a491add896e4e94da35be769927505a579f8`
   - Select all environments (Production, Preview, Development)

5. **Deploy**:
   - Click "Deploy"
   - Wait for deployment to complete

## Project Structure

```
aha-catcher/
├── api/
│   ├── transcribe.js    # Serverless function for transcription
│   └── chat.js          # Serverless function for research summary
├── index.html           # Main frontend app
├── package.json         # Dependencies
├── vercel.json          # Vercel configuration
└── .gitignore          # Git ignore file
```

## Environment Variables

**Required:**
- `API_KEY` - Your AI Builder API key

**Set in Vercel:**
1. Project Settings → Environment Variables
2. Add `API_KEY` with your API key value
3. Select all environments

## How It Works

### Vercel Serverless Functions

- `/api/transcribe` → Handles audio file uploads and transcription
- `/api/chat` → Handles chat completions for research summaries

### Frontend

- `index.html` → Served as static file
- Makes requests to `/api/transcribe` and `/api/chat`
- No CORS issues since everything is on the same domain

## Testing After Deployment

1. Visit your Vercel URL (e.g., `https://aha-catcher.vercel.app`)
2. Grant microphone permissions
3. Click "Capture Aha!" button
4. Verify transcription and research summary appear

## Troubleshooting

### "API_KEY environment variable not set"

**Solution:**
- Make sure you added the environment variable in Vercel
- Redeploy after adding the variable
- Check Project Settings → Environment Variables

### "Function timeout"

**Solution:**
- Vercel free tier has 10s timeout for Hobby plan
- Upgrade to Pro for longer timeouts
- Or optimize the API calls

### "CORS error"

**Solution:**
- Should not happen since everything is on same domain
- Check that API routes are in `/api` folder
- Verify `vercel.json` configuration

### "File upload failed"

**Solution:**
- Check that `busboy` is installed: `npm install busboy`
- Verify file size limits (Vercel has 4.5MB limit for serverless functions)
- Check browser console for errors

## Custom Domain (Optional)

1. Go to Project Settings → Domains
2. Add your custom domain
3. Follow DNS configuration instructions
4. Wait for DNS propagation

## Monitoring

- **Logs**: View in Vercel Dashboard → Project → Functions → Logs
- **Analytics**: Available in Vercel Dashboard
- **Deployments**: View all deployments in Dashboard

## Updating the Deployment

### Via CLI:
```bash
vercel --prod
```

### Via Git:
```bash
git add .
git commit -m "Update app"
git push
```
Vercel will automatically deploy on push (if connected to GitHub)

## Security Notes

⚠️ **Important:**
- API key is stored as environment variable (secure)
- Never commit API keys to Git
- Use Vercel's environment variables feature
- Consider rotating keys periodically

## Cost

- **Free Tier**: 
  - 100GB bandwidth/month
  - 100 serverless function invocations/day
  - Perfect for MVP/testing

- **Pro Tier**: 
  - $20/month
  - Unlimited bandwidth
  - Longer function timeouts
  - Better for production

## Next Steps

1. ✅ Deploy to Vercel
2. ✅ Test the deployment
3. ✅ Share your app URL
4. 📊 Monitor usage and errors
5. 🚀 Iterate and improve!

Your app will be live at: `https://your-project-name.vercel.app`

