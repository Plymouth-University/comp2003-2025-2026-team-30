const admin = require('firebase-admin');

function parseArgs(argv) {
    const result = {};

    for (let index = 0; index < argv.length; index += 1) {
        const arg = argv[index];
        if (!arg.startsWith('--')) {
            continue;
        }

        const next = argv[index + 1];
        if (!next || next.startsWith('--')) {
            result[arg.slice(2)] = true;
            continue;
        }

        result[arg.slice(2)] = next;
        index += 1;
    }

    return result;
}

function getValue(args, key, fallback = '') {
    return (args[key] || process.env[key.toUpperCase().replace(/-/g, '_')] || fallback).toString();
}

async function main() {
    const args = parseArgs(process.argv.slice(2));
    const projectId = getValue(args, 'project', process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || '');
    const speakingEvaluationEndpoint = getValue(args, 'speaking', process.env.SPEAKING_EVALUATION_ENDPOINT || '');
    const practiceFeedbackEndpoint = getValue(args, 'practice', process.env.PRACTICE_FEEDBACK_ENDPOINT || '');
    const translationEndpoint = getValue(args, 'translation', process.env.TRANSLATION_ENDPOINT || '');
    const model = getValue(args, 'model', 'gemini-2.5-flash');
    const provider = getValue(args, 'provider', 'vertex');

    if (!projectId) {
        throw new Error('Missing --project or GCLOUD_PROJECT.');
    }

    if (!speakingEvaluationEndpoint || !practiceFeedbackEndpoint) {
        throw new Error('Missing --speaking and/or --practice endpoint URL.');
    }

    if (admin.apps.length === 0) {
        admin.initializeApp({ projectId });
    }

    const firestore = admin.firestore();

    await firestore.collection('appConfig').doc('ai').set(
        {
            provider,
            model,
            speakingEvaluationEndpoint,
            practiceFeedbackEndpoint,
            ...(translationEndpoint ? { translationEndpoint } : {}),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
    );

    // Keep the output simple for a one-command setup flow.
    console.log(`Seeded appConfig/ai in project ${projectId}`);
    console.log(`provider=${provider}`);
    console.log(`model=${model}`);
    console.log(`speakingEvaluationEndpoint=${speakingEvaluationEndpoint}`);
    console.log(`practiceFeedbackEndpoint=${practiceFeedbackEndpoint}`);
    if (translationEndpoint) {
        console.log(`translationEndpoint=${translationEndpoint}`);
    }
}

main().catch((error) => {
    console.error(error.message || error);
    process.exit(1);
});