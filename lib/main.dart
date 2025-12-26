import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/storage/local_prefs.dart';
import 'core/data/data.dart';
import 'core/network/make_api_client.dart';
import 'core/network/rag_api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final localPrefs = await LocalPrefs.create();
  final resumeRepository = ResumeRepository();
  final apiClient = MakeApiClient();
  final ragApiClient = RagApiClient();

  runApp(
    PortfolioApp(
      localPrefs: localPrefs,
      resumeRepository: resumeRepository,
      apiClient: apiClient,
      ragApiClient: ragApiClient,
    ),
  );
}
