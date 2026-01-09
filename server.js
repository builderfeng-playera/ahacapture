// Simple Express proxy server to handle CORS
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const fetch = require('node-fetch');
const FormData = require('form-data');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3001;
const API_BASE_URL = 'https://space.ai-builders.com/backend';
const API_KEY = process.env.API_KEY || 'sk_e5ec71d9_a491add896e4e94da35be769927505a579f8'; // For local dev only

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Serve static files (index.html)
app.use(express.static(__dirname));

// Configure multer for file uploads
const upload = multer({ dest: 'uploads/' });

// Proxy endpoint for audio transcription
app.post('/api/transcribe', upload.single('audio_file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No audio file provided' });
        }

        // Create form data for the API
        const formData = new FormData();
        formData.append('audio_file', fs.createReadStream(req.file.path), {
            filename: req.file.originalname || 'recording.wav',
            contentType: req.file.mimetype || 'audio/wav'
        });

        // Forward request to AI Builder API
        const response = await fetch(`${API_BASE_URL}/v1/audio/transcriptions`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${API_KEY}`
            },
            body: formData
        });

        const data = await response.json();

        // Clean up uploaded file
        fs.unlinkSync(req.file.path);

        if (!response.ok) {
            return res.status(response.status).json(data);
        }

        res.json(data);
    } catch (error) {
        console.error('Transcription error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Proxy endpoint for chat completions (research summary)
app.post('/api/chat', async (req, res) => {
    try {
        const response = await fetch(`${API_BASE_URL}/v1/chat/completions`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${API_KEY}`
            },
            body: JSON.stringify(req.body)
        });

        const data = await response.json();

        if (!response.ok) {
            return res.status(response.status).json(data);
        }

        res.json(data);
    } catch (error) {
        console.error('Chat completion error:', error);
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`🚀 Proxy server running on http://localhost:${PORT}`);
    console.log(`📁 Serving files from: ${__dirname}`);
    console.log(`🔗 API Base URL: ${API_BASE_URL}`);
    console.log(`\n✅ Open http://localhost:${PORT} in your browser`);
});

