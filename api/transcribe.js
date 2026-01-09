// Vercel serverless function for audio transcription
const FormData = require('form-data');
const fetch = require('node-fetch');
const Busboy = require('busboy');

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const API_BASE_URL = 'https://space.ai-builders.com/backend';
    const API_KEY = process.env.API_KEY;

    if (!API_KEY) {
      return res.status(500).json({ error: 'API_KEY environment variable not set' });
    }

    // Parse multipart/form-data using Busboy
    return new Promise((resolve, reject) => {
      const busboy = Busboy({ headers: req.headers });
      const formData = new FormData();
      let fileReceived = false;

      busboy.on('file', (name, file, info) => {
        fileReceived = true;
        const { filename, encoding, mimeType } = info;
        formData.append('audio_file', file, {
          filename: filename || 'recording.wav',
          contentType: mimeType || 'audio/wav'
        });
      });

      busboy.on('finish', async () => {
        if (!fileReceived) {
          return resolve(res.status(400).json({ error: 'No audio file provided' }));
        }

        try {
          const response = await fetch(`${API_BASE_URL}/v1/audio/transcriptions`, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${API_KEY}`,
              ...formData.getHeaders()
            },
            body: formData
          });

          const data = await response.json();

          if (!response.ok) {
            return resolve(res.status(response.status).json(data));
          }

          resolve(res.json(data));
        } catch (error) {
          console.error('Transcription error:', error);
          reject(res.status(500).json({ error: error.message }));
        }
      });

      busboy.on('error', (error) => {
        console.error('Busboy error:', error);
        reject(res.status(500).json({ error: error.message }));
      });

      req.pipe(busboy);
    });
  } catch (error) {
    console.error('Transcription error:', error);
    res.status(500).json({ error: error.message });
  }
};

