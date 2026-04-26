# adaptive_english_learning_app

English learning app prototype with Firebase auth, Firestore-backed profiles, and AI practice screens.

## Vertex AI / Gemini setup

The Flutter app does not call Vertex AI directly. It posts practice attempts to a backend HTTPS endpoint, and that backend calls Gemini on Vertex AI securely.

### 1. Enable Google Cloud services

1. Create or select a Google Cloud project linked to your Firebase project.
2. Enable the Vertex AI API.
3. Make sure billing is enabled for the project.
4. Create a service account for the backend with permission to call Vertex AI.

### 2. Build the backend endpoint

Create two HTTPS endpoints, or one endpoint that routes by `activityType`:

1. Pronunciation evaluation endpoint.
2. General practice feedback endpoint.

The app sends JSON like this:

```json
{
	"prompt": "Introduce yourself in two sentences.",
	"responseText": "mi name is favour",
	"provider": "vertex",
	"model": "gemini-2.5-flash",
	"activityType": "speaking",
	"profile": {
		"nativeLanguage": "French",
		"proficiencyLevel": "beginner",
		"learningGoal": "travel",
		"learningStyle": "visual"
	}
}
```

The backend should return JSON in this shape:

```json
{
	"score": 82,
	"feedback": "...",
	"correctedTranscript": "...",
	"nextStep": "...",
	"provider": "vertex",
	"model": "gemini-2.5-flash"
}
```

### 3. Store the endpoint in Firestore

Create this document:

- Collection: `appConfig`
- Document: `ai`

Recommended fields:

- `provider`: `vertex`
- `model`: `gemini-2.5-flash`
- `speakingEvaluationEndpoint`: your HTTPS speech feedback URL
- `practiceFeedbackEndpoint`: your HTTPS text feedback URL

If either endpoint is missing, the app falls back to local heuristic feedback.

### 4. How Flutter connects

The app already reads the Firestore config in `lib/services/ai_tutor_service.dart` and sends the current user profile snapshot from the practice screens. No extra refetch is needed before evaluation.

Relevant files:

- [lib/services/ai_tutor_service.dart](lib/services/ai_tutor_service.dart)
- [lib/practice/pronunciation_practice_screen.dart](lib/practice/pronunciation_practice_screen.dart)
- [lib/practice/ai_text_practice_screen.dart](lib/practice/ai_text_practice_screen.dart)

### 5. Minimal backend contract

Your backend can be a Firebase Cloud Function, Cloud Run service, or any HTTPS API. The only requirement is:

1. Accept the request body above.
2. Use the prompt, response text, and profile data to call Gemini on Vertex AI.
3. Return structured JSON with score and feedback.

There is a starter Firebase Cloud Functions implementation in [backend/index.js](../../backend/index.js) with deploy notes in [backend/README.md](../../backend/README.md).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
