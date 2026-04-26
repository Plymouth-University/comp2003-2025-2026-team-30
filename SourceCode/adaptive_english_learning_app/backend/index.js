const { onRequest } = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');
const { VertexAI } = require('@google-cloud/vertexai');

const DEFAULT_LOCATION = process.env.VERTEX_AI_LOCATION || 'us-central1';
const DEFAULT_MODEL = process.env.VERTEX_AI_MODEL || 'gemini-2.5-flash';

function getProjectId() {
    return (
        process.env.GCLOUD_PROJECT ||
        process.env.GCP_PROJECT ||
        process.env.GOOGLE_CLOUD_PROJECT ||
        ''
    );
}

function createVertexModel(modelName) {
    const project = getProjectId();

    if (!project) {
        throw new Error('Missing Google Cloud project id. Set GCLOUD_PROJECT in the runtime environment.');
    }

    const vertexAI = new VertexAI({ project, location: DEFAULT_LOCATION });

    return vertexAI.getGenerativeModel({
        model: modelName || DEFAULT_MODEL,
        generationConfig: {
            temperature: 0.2,
            topP: 0.95,
            maxOutputTokens: 1024,
            responseMimeType: 'application/json',
        },
        systemInstruction: {
            parts: [
                {
                    text:
                        'You are an English learning coach. Return only valid JSON with keys score, feedback, correctedTranscript, nextStep, provider, and model. Keep feedback under 20 words and nextStep under 16 words. Keep correctedTranscript short. Score must be an integer from 0 to 100.',
                },
            ],
        },
    });
}

function normalizeProfile(profile) {
    return {
        nativeLanguage: profile?.nativeLanguage || '',
        proficiencyLevel: profile?.proficiencyLevel || '',
        learningGoal: profile?.learningGoal || '',
        learningStyle: profile?.learningStyle || '',
    };
}

function buildPrompt({ activityType, prompt, responseText, profile }) {
    const profileSummary = JSON.stringify(normalizeProfile(profile));

    if (activityType === 'speaking') {
        return [
            'Evaluate this English pronunciation attempt.',
            `Prompt: ${prompt}`,
            `Transcript: ${responseText}`,
            `Learner profile: ${profileSummary}`,
            'Return JSON only. Focus on pronunciation, fluency, grammar, and one short correctedTranscript suggestion. Do not add explanations.',
        ].join('\n');
    }

    return [
        'Evaluate this English practice response.',
        `Prompt: ${prompt}`,
        `Response: ${responseText}`,
        `Learner profile: ${profileSummary}`,
            'Return JSON only. Focus on task completion, vocabulary, grammar, and one short correctedTranscript suggestion. Do not add explanations.',
    ].join('\n');
}

function parseModelJson(text, fallback) {
    if (!text || typeof text !== 'string') {
        return fallback;
    }

    const trimmed = text.trim();
    const jsonText = trimmed.startsWith('```')
        ? trimmed.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '')
        : trimmed;

    const braceStart = jsonText.indexOf('{');
    const braceEnd = jsonText.lastIndexOf('}');
    const candidateJson = braceStart >= 0 && braceEnd > braceStart
        ? jsonText.slice(braceStart, braceEnd + 1)
        : jsonText;

    try {
        return JSON.parse(candidateJson);
    } catch (error) {
        logger.warn('Failed to parse Gemini JSON response, falling back to heuristic wrapper.', {
            error: String(error),
            text: trimmed,
            candidateJson,
        });
        return fallback;
    }
}

async function evaluateAttempt(req, res) {
    if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method not allowed' });
        return;
    }

    const {
        activityType = 'speaking',
        prompt,
        responseText,
        provider = 'vertex',
        model = DEFAULT_MODEL,
        profile = {},
    } = req.body || {};

    if (!prompt || !responseText) {
        res.status(400).json({ error: 'Missing prompt or responseText.' });
        return;
    }

    try {
        const generativeModel = createVertexModel(model);
        const requestPrompt = buildPrompt({ activityType, prompt, responseText, profile });
        const result = await generativeModel.generateContent(requestPrompt);
        const text = result?.response?.candidates?.[0]?.content?.parts?.[0]?.text || result?.response?.text?.();

        const fallback = {
            score: 0,
            feedback: 'Gemini returned no usable response.',
            correctedTranscript: responseText,
            nextStep: 'Try again with a clearer utterance or response.',
            source: 'local-fallback',
            provider,
            model,
        };

        const parsed = parseModelJson(text, fallback);
        const score = Number.isFinite(Number(parsed.score)) ? Number(parsed.score) : 0;

        res.status(200).json({
            score,
            feedback: parsed.feedback || fallback.feedback,
            correctedTranscript: parsed.correctedTranscript || responseText,
            nextStep: parsed.nextStep || fallback.nextStep,
            source: parsed.source || 'ai',
            provider: parsed.provider || provider,
            model: parsed.model || model,
        });
    } catch (error) {
        logger.error('Gemini/Vertex evaluation failed', { error: String(error) });
        res.status(500).json({
            error: 'AI evaluation failed.',
            details: String(error),
        });
    }
}

exports.evaluateSpeakingAttempt = onRequest({ cors: true, invoker: 'public' }, evaluateAttempt);
exports.evaluatePracticeFeedback = onRequest({ cors: true, invoker: 'public' }, evaluateAttempt);