import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AiTutorConfig {
  const AiTutorConfig({
    required this.provider,
    required this.model,
    required this.speakingEvaluationEndpoint,
    required this.practiceFeedbackEndpoint,
    required this.translationEndpoint,
  });

  final String provider;
  final String model;
  final String? speakingEvaluationEndpoint;
  final String? practiceFeedbackEndpoint;
  final String? translationEndpoint;

  factory AiTutorConfig.fromMap(Map<String, dynamic> data) {
    return AiTutorConfig(
      provider: (data['provider'] as String?) ?? 'vertex',
      model: (data['model'] as String?) ?? 'gemini-2.5-flash',
      speakingEvaluationEndpoint: data['speakingEvaluationEndpoint'] as String?,
      practiceFeedbackEndpoint: data['practiceFeedbackEndpoint'] as String?,
      translationEndpoint: data['translationEndpoint'] as String?,
    );
  }
}

class AiTutorService {
  AiTutorService({FirebaseFirestore? firestore, http.Client? client})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _client = client ?? http.Client();

  final FirebaseFirestore _firestore;
  final http.Client _client;

  Future<AiTutorConfig> loadConfig() async {
    final aiConfigSnapshot = await _firestore
        .collection('appConfig')
        .doc('ai')
        .get();
    return AiTutorConfig.fromMap(
      aiConfigSnapshot.data() ?? <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> evaluateSpeakingAttempt({
    required String prompt,
    required String transcript,
    Map<String, dynamic>? profileData,
  }) async {
    final profile = profileData ?? await _loadCurrentUserProfile();

    final config = await loadConfig();
    final endpoint = config.speakingEvaluationEndpoint;

    if (endpoint == null || endpoint.isEmpty) {
      return _heuristicEvaluation(
        prompt: prompt,
        transcript: transcript,
        provider: 'local-fallback',
        model: config.model,
        profile: profile,
      );
    }

    return _callBackend(
      endpoint: endpoint,
      provider: config.provider,
      model: config.model,
      prompt: prompt,
      responseText: transcript,
      profile: profile,
      fallback: () => _heuristicEvaluation(
        prompt: prompt,
        transcript: transcript,
        provider: 'local-fallback',
        model: config.model,
        profile: profile,
      ),
    );
  }

  Future<Map<String, dynamic>> evaluateTextAttempt({
    required String activityType,
    required String prompt,
    required String responseText,
    Map<String, dynamic>? profileData,
  }) async {
    final profile = profileData ?? await _loadCurrentUserProfile();
    final config = await loadConfig();
    final endpoint = config.practiceFeedbackEndpoint;

    if (endpoint == null || endpoint.isEmpty) {
      return _heuristicTextEvaluation(
        activityType: activityType,
        prompt: prompt,
        responseText: responseText,
        provider: 'local-fallback',
        model: config.model,
      );
    }

    return _callBackend(
      endpoint: endpoint,
      provider: config.provider,
      model: config.model,
      prompt: prompt,
      responseText: responseText,
      profile: profile,
      extraPayload: {'activityType': activityType},
      fallback: () => _heuristicTextEvaluation(
        activityType: activityType,
        prompt: prompt,
        responseText: responseText,
        provider: 'local-fallback',
        model: config.model,
      ),
    );
  }

  Future<Map<String, dynamic>> _loadCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return <String, dynamic>{};
    }

    final profileSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    return profileSnapshot.data() ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _callBackend({
    required String endpoint,
    required String provider,
    required String model,
    required String prompt,
    required String responseText,
    required Map<String, dynamic> profile,
    required Map<String, dynamic> Function() fallback,
    Map<String, dynamic> extraPayload = const {},
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'responseText': responseText,
          'provider': provider,
          'model': model,
          'profile': {
            'nativeLanguage': profile['nativeLanguage'],
            'proficiencyLevel': profile['proficiencyLevel'],
            'learningGoal': profile['learningGoal'],
            'learningStyle': profile['learningStyle'],
          },
          ...extraPayload,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return fallback();
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final source = (decoded['source'] as String?) ?? 'ai';
      final isFallback = source == 'local-fallback';
      return {
        'score': decoded['score'] ?? 0,
        'feedback':
            decoded['feedback'] ??
            (isFallback
                ? 'Local practice mode is showing a quick estimate.'
                : 'No feedback returned.'),
        'correctedTranscript': decoded['correctedTranscript'] ?? responseText,
        'nextStep':
            decoded['nextStep'] ??
            (isFallback
                ? 'Try again after the AI service is available.'
                : 'Try again with clearer pacing.'),
        'source': source,
        'isFallback': isFallback,
        'statusMessage': isFallback
            ? 'Local practice mode is on because the AI service is unavailable right now.'
            : 'AI feedback is ready.',
        'provider': decoded['provider'] ?? provider,
        'model': decoded['model'] ?? model,
      };
    } catch (_) {
      return fallback();
    }
  }

  Map<String, dynamic> _heuristicEvaluation({
    required String prompt,
    required String transcript,
    required String provider,
    required String model,
    required Map<String, dynamic> profile,
  }) {
    final promptWords = prompt
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .toSet();
    final transcriptWords = transcript.toLowerCase().split(RegExp(r'\s+'));
    final matched = transcriptWords.where(promptWords.contains).length;
    final lengthScore = transcriptWords.length >= 5 ? 35 : 15;
    final relevanceScore = (matched * 10).clamp(0, 40);
    final clarityScore = transcript.trim().isEmpty ? 0 : 25;
    final score = (lengthScore + relevanceScore + clarityScore).clamp(0, 100);

    return {
      'score': score,
      'feedback':
          'Local practice mode is showing a quick estimate while AI feedback is unavailable.',
      'correctedTranscript': transcript.isEmpty
          ? 'No speech captured yet.'
          : transcript,
      'nextStep': 'Try again once AI feedback is back online.',
      'source': 'local-fallback',
      'isFallback': true,
      'statusMessage':
          'Local practice mode is on because the AI service is unavailable right now.',
      'provider': provider,
      'model': model,
      'profile': profile,
    };
  }

  Map<String, dynamic> _heuristicTextEvaluation({
    required String activityType,
    required String prompt,
    required String responseText,
    required String provider,
    required String model,
  }) {
    final promptWords = prompt
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .toSet();
    final responseWords = responseText.toLowerCase().split(RegExp(r'\s+'));
    final matched = responseWords.where(promptWords.contains).length;
    final richnessScore = responseWords.toSet().length >= 8 ? 35 : 20;
    final relevanceScore = (matched * 8).clamp(0, 35);
    final completionScore = responseText.trim().isEmpty ? 0 : 25;
    final score = (richnessScore + relevanceScore + completionScore).clamp(
      0,
      100,
    );

    return {
      'score': score,
      'feedback':
          'Local practice mode is showing a quick estimate while AI feedback is unavailable.',
      'correctedTranscript': responseText.isEmpty
          ? 'No response captured yet.'
          : responseText,
      'nextStep': 'Try again once AI feedback is back online.',
      'source': 'local-fallback',
      'isFallback': true,
      'statusMessage':
          'Local practice mode is on because the AI service is unavailable right now.',
      'provider': provider,
      'model': model,
    };
  }
}
