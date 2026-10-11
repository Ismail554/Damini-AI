import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Adversarial Parity Challenge: ApiEndpoints vs BACKEND_API_AUDIT_REPORT.md', () {
    late String apiEndpointsContent;
    late String auditReportContent;

    setUpAll(() {
      final endpointsFile = File('lib/core/constants/api_endpoints.dart');
      expect(endpointsFile.existsSync(), isTrue, reason: 'api_endpoints.dart must exist');
      apiEndpointsContent = endpointsFile.readAsStringSync();

      final reportFile = File('BACKEND_API_AUDIT_REPORT.md');
      expect(reportFile.existsSync(), isTrue, reason: 'BACKEND_API_AUDIT_REPORT.md must exist');
      auditReportContent = reportFile.readAsStringSync();
    });

    test('Inventory Parity: Every constant and method in ApiEndpoints is audited in BACKEND_API_AUDIT_REPORT.md', () {
      final constRegex = RegExp(r'static\s+const\s+String\s+(\w+)\s*=\s*"([^"]+)";');
      final constMatches = constRegex.allMatches(apiEndpointsContent).toList();

      final methodRegex = RegExp(r'static\s+String\s+(\w+)\s*\(([^)]*)\)\s*(?:=>\s*"([^"]+)"|\{([\s\S]*?)\})');
      final methodMatches = methodRegex.allMatches(apiEndpointsContent).toList();

      expect(constMatches.length + methodMatches.length + 1, equals(65),
          reason: 'Expected exactly 65 members (1 getter baseUrl, ${constMatches.length} constants, ${methodMatches.length} methods)');

      final missing = <String>[];

      // 1. baseUrl getter
      expect(auditReportContent.contains('baseUrl') || auditReportContent.contains('https://clubby-andy-irksomely.ngrok-free.dev'), isTrue);

      // 2. Constants
      for (final m in constMatches) {
        final name = m.group(1)!;
        final url = m.group(2)!;
        final urlWithoutSlash = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

        final audited = auditReportContent.contains(url) ||
            auditReportContent.contains(urlWithoutSlash) ||
            auditReportContent.contains(name);

        if (!audited) {
          missing.add('$name ($url)');
        }
      }

      // 3. Methods
      for (final m in methodMatches) {
        final name = m.group(1)!;
        final expr = m.group(3);

        bool audited = auditReportContent.contains(name);
        if (!audited && expr != null) {
          final cleanExpr = expr.replaceAll(RegExp(r'(\$\{[^}]+\}|\$[a-zA-Z0-9_]+)'), '');
          audited = auditReportContent.contains(cleanExpr);
        }
        if (!audited && name == 'chatWebSocket') {
          audited = auditReportContent.contains('/ws/chat/');
        }

        if (!audited) {
          missing.add('$name (method)');
        }
      }

      expect(missing, isEmpty, reason: 'All members of ApiEndpoints must be audited in the report');
    });

    test('Orphan Verification: discoverProjects has zero callers in lib/ except its declaration', () {
      final libDir = Directory('lib');
      final dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

      int referencesCount = 0;
      final referencingFiles = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (content.contains('discoverProjects')) {
          referencesCount++;
          referencingFiles.add(file.path);
        }
      }

      expect(referencesCount, equals(1),
          reason: 'discoverProjects should only appear in its own declaration in api_endpoints.dart');
      expect(referencingFiles.first.replaceAll('\\', '/'), contains('lib/core/constants/api_endpoints.dart'));

      // Check DiscoverRepository specifically uses projects instead of discoverProjects
      final discoverRepoFile = File('lib/views/investor/discover/repositories/discover_repository.dart');
      expect(discoverRepoFile.existsSync(), isTrue);
      final discoverRepoContent = discoverRepoFile.readAsStringSync();
      expect(discoverRepoContent.contains('ApiEndpoints.projects'), isTrue);
      expect(discoverRepoContent.contains('ApiEndpoints.discoverProjects'), isFalse);
    });

    test('Mock Fallback Verification: All 12 reported repositories contain mock fallbacks or stubs', () {
      final repos = <String, String>{
        'InvestmentHistoryRepositoryImpl':
            'lib/views/investor/investment_history/repositories/investment_history_repository.dart',
        'InvestorDashboardRepositoryImpl':
            'lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart',
        'DiscoverRepositoryImpl':
            'lib/views/investor/discover/repositories/discover_repository.dart',
        'InvestorSavedRepositoryImpl':
            'lib/views/investor/saved/repositories/investor_saved_repository.dart',
        'InvestorChatRepositoryImpl':
            'lib/views/investor/chat/repositories/investor_chat_repository.dart',
        'ChatRepository':
            'lib/views/sponsor/chat/repositories/chat_repository.dart',
        'NdaRepository':
            'lib/views/sponsor/nda/repositories/nda_repository.dart',
        'ProjectPublicRepository':
            'lib/views/sponsor/public_view/repositories/project_public_repository.dart',
        'SponsorProfileRepository':
            'lib/views/sponsor/profile/repositories/sponsor_profile_repository.dart',
        'OpportunityRepositoryImpl':
            'lib/data/repositories/opportunity_repository.dart',
        'HomeRepositoryImpl':
            'lib/views/home/repositories/home_repository.dart',
        'GroupChatRepositoryImpl':
            'lib/views/sponsor/group_chat/repositories/group_chat_repository.dart',
      };

      for (final entry in repos.entries) {
        final name = entry.key;
        final path = entry.value;
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$name at $path must exist');
        final content = file.readAsStringSync();

        // Each repo must have catch (_) fallback, mockData(), stub return, or hardcoded mock list
        final hasMockData = content.contains('mockData') ||
            content.contains('_mock') ||
            content.contains('Future.delayed') ||
            content.contains('inv_hist_1') ||
            content.contains('deal_trending_1') ||
            content.contains('inv_saved_1') ||
            content.contains('chat_1') ||
            content.contains('ahmad_1') ||
            content.contains('return 0;') ||
            content.contains('return const [];') ||
            content.contains('name: "Member"');

        expect(hasMockData, isTrue,
            reason: '$name ($path) must contain verifiable mock fallback or stub code');
      }
    });
  });
}
