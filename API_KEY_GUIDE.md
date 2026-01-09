# API Key Guide: Finding and Using Your API Key

## What is an API Key?

An **API key** is a unique identifier (like a password) that authenticates your requests to an API. It tells the server "I'm authorized to use this service."

Think of it like:
- A **library card** - proves you're a member
- A **key to a building** - grants you access
- A **password** - authenticates your identity

## Finding Your AI Builder API Key

### Step 1: Access the Student Portal

1. Log in to the **AI Builder Student Portal**
2. Navigate to the section: **"Commanding AI with the platform's offering"**
   - This is typically in the course materials or resources section
   - Look for API documentation or integration guides

### Step 2: Locate Your API Key

The API key is usually displayed in one of these places:
- **API Keys section** - A dedicated page showing your keys
- **Account Settings** - Under your profile/account settings
- **Developer Dashboard** - If there's a developer portal
- **Course Materials** - Embedded in lesson content

### Step 3: Copy Your API Key

API keys typically look like one of these formats:
```
sk-1234567890abcdefghijklmnopqrstuvwxyz
AI_BUILDER_1234567890abcdefghijklmnopqrstuvwxyz
ab1234567890abcdefghijklmnopqrstuvwxyz1234567890
```

**Important:** Copy the entire key - it's usually a long string of letters and numbers.

## Using Your API Key

### In the Web MVP (index.html)

1. Open `index.html` in a text editor
2. Find this line:
   ```javascript
   const API_KEY = 'YOUR_API_KEY_HERE';
   ```
3. Replace `'YOUR_API_KEY_HERE'` with your actual key:
   ```javascript
   const API_KEY = 'sk-1234567890abcdefghijklmnopqrstuvwxyz';
   ```
4. Save the file

### In the Apple Watch App (AhaCatcherApp.swift)

1. Open `AhaCatcherApp.swift`
2. Find this line:
   ```swift
   request.setValue("Bearer YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
   ```
3. Replace `YOUR_API_TOKEN` with your actual key:
   ```swift
   request.setValue("Bearer sk-1234567890abcdefghijklmnopqrstuvwxyz", forHTTPHeaderField: "Authorization")
   ```

## API Key Security Best Practices

### ✅ DO:
- **Keep it secret** - Never share your API key publicly
- **Use environment variables** - Store keys outside your code
- **Rotate regularly** - Change keys periodically
- **Use different keys** - Separate keys for development/production
- **Monitor usage** - Check for unauthorized access

### ❌ DON'T:
- **Commit to Git** - Never commit API keys to version control
- **Share publicly** - Don't post keys on forums, GitHub, etc.
- **Hardcode in production** - Use secure storage instead
- **Use the same key everywhere** - Create separate keys for different apps

## Secure Storage Options

### For Web Development

**Option 1: Environment Variables**
```javascript
// Use environment variable instead of hardcoding
const API_KEY = process.env.API_KEY || '';
```

**Option 2: Config File (not in Git)**
```javascript
// config.js (add to .gitignore)
const API_KEY = 'your-key-here';
```

**Option 3: User Input (for testing)**
```javascript
// Prompt user for key (not for production)
const API_KEY = prompt('Enter your API key:');
```

### For Mobile Development

**Option 1: Environment Variables**
```swift
// Use environment variable
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
```

**Option 2: Secure Keychain (iOS)**
```swift
// Store in iOS Keychain for secure storage
import Security

// Store key
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "api_key",
    kSecValueData as String: apiKey.data(using: .utf8)!
]
SecItemAdd(query as CFDictionary, nil)

// Retrieve key
let getQuery: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "api_key",
    kSecReturnData as String: true
]
var result: AnyObject?
SecItemCopyMatching(getQuery as CFDictionary, &result)
```

## Testing Your API Key

### Quick Test Script

Create a test file to verify your API key works:

```javascript
// test-api-key.js
const API_KEY = 'YOUR_API_KEY_HERE';
const API_BASE_URL = 'https://space.ai-builders.com/backend';

async function testAPIKey() {
    try {
        const response = await fetch(`${API_BASE_URL}/v1/models`, {
            headers: {
                'Authorization': `Bearer ${API_KEY}`
            }
        });
        
        if (response.ok) {
            const data = await response.json();
            console.log('✅ API Key is valid!');
            console.log('Available models:', data.data.map(m => m.id));
        } else {
            console.error('❌ API Key is invalid or expired');
            console.error('Status:', response.status);
        }
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

testAPIKey();
```

Run with: `node test-api-key.js`

## Common API Key Formats

Different services use different formats:

| Service | Format Example |
|---------|---------------|
| OpenAI | `sk-...` (starts with "sk-") |
| Google Cloud | `AIza...` (starts with "AIza") |
| AWS | `AKIA...` (starts with "AKIA") |
| Custom APIs | Varies (usually long alphanumeric strings) |

## Troubleshooting

### "Invalid API Key" Error

1. **Check for typos** - Copy/paste the entire key
2. **Check for extra spaces** - Remove leading/trailing whitespace
3. **Verify key format** - Make sure it matches expected format
4. **Check expiration** - Some keys expire after a period
5. **Check permissions** - Ensure key has required permissions

### "Unauthorized" Error

1. **Check Authorization header** - Should be `Bearer YOUR_KEY`
2. **Check key permissions** - Key might not have access to that endpoint
3. **Check account status** - Account might be suspended or inactive

### "API Key Not Found" Error

1. **Verify you're using the right key** - Check Student Portal again
2. **Check if key was regenerated** - Old keys become invalid
3. **Contact support** - If key should work but doesn't

## What to Do If Your Key is Compromised

1. **Immediately revoke the key** - In Student Portal, delete/revoke it
2. **Generate a new key** - Create a replacement
3. **Update all applications** - Replace old key everywhere
4. **Monitor usage** - Check for unauthorized access
5. **Review security** - Identify how it was compromised

## Alternative: Using API Keys Securely in Production

For production applications, consider:

1. **Backend Proxy** - Store key on server, client calls your server
2. **OAuth 2.0** - More secure authentication flow
3. **API Key Management Service** - Use services like AWS Secrets Manager
4. **Rate Limiting** - Implement on your backend

## Example: Secure Implementation

### Backend Proxy Pattern (Recommended for Production)

```javascript
// Frontend (index.html) - No API key exposed
async function transcribeAudio(audioBlob) {
    // Call YOUR backend, not the API directly
    const response = await fetch('/api/transcribe', {
        method: 'POST',
        body: audioBlob
    });
    return await response.json();
}

// Backend (server.js) - API key stored securely
app.post('/api/transcribe', async (req, res) => {
    const apiKey = process.env.API_KEY; // From environment variable
    // Forward request to AI Builder API with key
    const response = await fetch('https://space.ai-builders.com/backend/v1/audio/transcriptions', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${apiKey}`
        },
        body: req.body
    });
    const data = await response.json();
    res.json(data);
});
```

## Summary

1. **Find your key** in Student Portal → "Commanding AI with the platform's offering"
2. **Copy it carefully** - Get the entire string
3. **Use it securely** - Don't commit to Git, use environment variables
4. **Test it** - Verify it works before building your app
5. **Keep it secret** - Never share publicly

## Next Steps

1. Log into Student Portal
2. Find the API key section
3. Copy your key
4. Update `index.html` with your key
5. Test the application

If you can't find your API key, contact your instructor or check the course materials for the exact location.

