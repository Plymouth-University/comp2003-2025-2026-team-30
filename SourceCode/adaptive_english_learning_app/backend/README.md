# Backend AI endpoint

This folder contains the minimal Firebase Cloud Functions backend that the Flutter app expects for real Gemini feedback.

## What it does

It exposes two HTTPS endpoints:

1. `evaluateSpeakingAttempt`
2. `evaluatePracticeFeedback`

Both endpoints accept the same JSON payload from the Flutter practice screens and call Gemini on Vertex AI.

## Environment

Set these runtime values in your Firebase/Google Cloud environment:

- `VERTEX_AI_LOCATION` = `us-central1`
- `VERTEX_AI_MODEL` = `gemini-2.5-flash`

The function uses the active Google Cloud project id from the runtime metadata.

## Permissions checklist

The backend runtime identity must have access to Vertex AI and Firestore.

For Vertex AI calls, grant the runtime service account:

- `Vertex AI User` or `Vertex AI Administrator`

If you use the seeder script, the account running it also needs:

- `Cloud Datastore User` or `Firestore Admin`

For function deployment builds, the Cloud Build service account also needs write access to build artifacts. If deploy fails with a message about the build service account, grant the default Compute service account:

- `Cloud Build Service Account` (`roles/cloudbuild.builds.builder`)

If your organization uses a custom build service account, grant that account the same role set instead.

Important: the service account shown in the Cloud Console screenshot must be the same identity your deployed backend actually runs as. If your Cloud Function or Cloud Run service uses a different runtime account, that is the one that needs the Vertex AI role.

## Install and deploy

From this folder:

```bash
npm install
firebase deploy --only functions
```

If Firebase still says it cannot find `firebase.json`, make sure you are running the command in this `backend` folder after adding the files above.

## Windows setup for `gcloud` and application-default credentials

1. Install the Google Cloud CLI for Windows from the official installer.
2. Close PowerShell and reopen it after installation.
3. Verify the CLI is available:

```powershell
gcloud --version
```

4. Sign in for normal CLI access:

```powershell
gcloud auth login
```

5. Set application-default credentials for the seeder script:

```powershell
gcloud auth application-default login
```

6. Verify the ADC file is present by running:

```powershell
gcloud auth application-default print-access-token
```

If that command prints a token instead of an error, the seeder can write to Firestore.

The function URLs from deploy are meant to be called with `POST`. A browser `GET` can still show an error page even when the deployment is correct.

## Seed the Firestore config

Use the included script to create or update `appConfig/ai` before testing the app:

```bash
npm run seed:ai -- --project YOUR_FIREBASE_PROJECT_ID --speaking https://YOUR_SPEAKING_ENDPOINT --practice https://YOUR_PRACTICE_ENDPOINT
```

You can also set `GCLOUD_PROJECT`, `SPEAKING_EVALUATION_ENDPOINT`, and `PRACTICE_FEEDBACK_ENDPOINT` as environment variables instead of passing CLI flags.

## Firestore config

Write the deployed function URLs into `appConfig/ai` in Firestore:

- `speakingEvaluationEndpoint`
- `practiceFeedbackEndpoint`

Keep `provider` set to `vertex` and `model` set to the model you deploy.

The document should look like this:

```json
{
	"provider": "vertex",
	"model": "gemini-2.5-flash",
	"speakingEvaluationEndpoint": "https://...",
	"practiceFeedbackEndpoint": "https://..."
}
```

If the `appConfig/ai` document is missing, the Flutter app falls back to local scoring instead of real Gemini feedback.