const fs = require('fs');
const axios = require('axios');

const ASSEMBLY_BASE_URL = process.env.ASSEMBLYAI_BASE_URL || 'https://api.assemblyai.com/v2';
const POLL_INTERVAL_MS = Number(process.env.ASSEMBLYAI_POLL_INTERVAL_MS) || 4000;
const REQUEST_TIMEOUT_MS = Number(process.env.ASSEMBLYAI_REQUEST_TIMEOUT_MS) || 120000;
const OVERALL_TIMEOUT_MS = Number(process.env.ASSEMBLYAI_TIMEOUT_MS) || 180000;

class SttService {
  constructor() {
    this.apiKey = process.env.ASSEMBLYAI_API_KEY;
    this.http = axios.create({
      baseURL: ASSEMBLY_BASE_URL,
      maxContentLength: Infinity,
      maxBodyLength: Infinity,
      timeout: REQUEST_TIMEOUT_MS,
    });

    if (!this.apiKey) {
      console.warn('[STT] ASSEMBLYAI_API_KEY is missing. Speech-to-text endpoint will fail until it is configured.');
    }
  }

  async transcribeAudio(filePath, options = {}) {
    this.ensureApiKey();

    const uploadUrl = await this.uploadAudio(filePath);
    const transcriptId = await this.createTranscription(uploadUrl, options);
    const transcript = await this.pollTranscription(transcriptId);

    return transcript.text?.trim() || '';
  }

  ensureApiKey() {
    if (!this.apiKey) {
      throw new Error('ASSEMBLYAI_API_KEY is not configured');
    }
  }

  buildHeaders(extraHeaders = {}) {
    return {
      authorization: this.apiKey,
      ...extraHeaders,
    };
  }

  async uploadAudio(filePath) {
    const audioStream = fs.createReadStream(filePath);

    const response = await this.http.post('/upload', audioStream, {
      headers: this.buildHeaders({ 'content-type': 'application/octet-stream' }),
    });

    if (!response.data?.upload_url) {
      throw new Error('AssemblyAI upload failed');
    }

    return response.data.upload_url;
  }

  async createTranscription(audioUrl, { language } = {}) {
    const payload = {
      audio_url: audioUrl,
      language_code: language,
      format_text: true,
      disfluencies: false,
    };

    const response = await this.http.post('/transcript', payload, {
      headers: this.buildHeaders({ 'content-type': 'application/json' }),
    });

    if (!response.data?.id) {
      throw new Error('AssemblyAI transcription request failed');
    }

    return response.data.id;
  }

  async pollTranscription(transcriptId) {
    const startedAt = Date.now();

    while (true) {
      if (Date.now() - startedAt > OVERALL_TIMEOUT_MS) {
        throw new Error('AssemblyAI transcription timed out');
      }

      const response = await this.http.get(`/transcript/${transcriptId}`, {
        headers: this.buildHeaders(),
      });

      const { status, text, error } = response.data || {};

      if (status === 'completed') {
        return response.data;
      }

      if (status === 'error') {
        throw new Error(error || 'AssemblyAI transcription failed');
      }

      await this.sleep(POLL_INTERVAL_MS);
    }
  }

  async sleep(durationMs) {
    return new Promise((resolve) => setTimeout(resolve, durationMs));
  }
}

module.exports = new SttService();
