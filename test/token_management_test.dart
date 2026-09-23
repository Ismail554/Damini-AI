import 'package:Braintech/core/services/storage_service.dart';
import 'package:Braintech/shared/global_key.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('StorageService Token & Role Persistence Tests', () {
    test('saving and retrieving non-empty access & refresh tokens', () async {
      await StorageService.saveToken('test_access_token');
      await StorageService.saveRefreshToken('test_refresh_token');

      final access = await StorageService.getToken();
      final refresh = await StorageService.getRefreshToken();

      expect(access, 'test_access_token');
      expect(refresh, 'test_refresh_token');
    });

    test('empty or whitespace token is not saved or returned as valid', () async {
      await StorageService.saveToken('   ');
      final access = await StorageService.getToken();
      expect(access, isNull);

      await StorageService.saveRefreshToken('');
      final refresh = await StorageService.getRefreshToken();
      expect(refresh, isNull);
    });

    test('clearRole removes role and isRoleSelected flag', () async {
      await StorageService.saveRole('investor');
      expect(await StorageService.getRole(), 'investor');
      expect(await StorageService.isRoleSelected(), true);

      await StorageService.clearRole();
      expect(await StorageService.getRole(), isNull);
      expect(await StorageService.isRoleSelected(), false);
    });

    test('clearAll clears all session tokens and flags', () async {
      await StorageService.saveToken('token_1');
      await StorageService.saveRefreshToken('refresh_1');
      await StorageService.saveRole('sponsor');

      await StorageService.clearAll();

      expect(await StorageService.getToken(), isNull);
      expect(await StorageService.getRefreshToken(), isNull);
      expect(await StorageService.getRole(), isNull);
      expect(await StorageService.isRoleSelected(), false);
    });
  });

  group('SessionNotifier checkAuthStatus Persistence Tests', () {
    test('valid token and valid role restores authenticated session with role', () async {
      await StorageService.saveToken('persisted_token');
      await StorageService.saveRole('investor');
      await StorageService.saveIsApiConnected(true);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isAuth = await container.read(sessionProvider.notifier).checkAuthStatus();
      final state = container.read(sessionProvider);

      expect(isAuth, true);
      expect(state.isAuthenticated, true);
      expect(state.userRole, 'investor');
      expect(GlobalKeys.isValidRole(state.userRole), true);
    });

    test('valid token with NONE/invalid role restores authenticated session with null role', () async {
      await StorageService.saveToken('persisted_token');
      await StorageService.saveRole('NONE');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isAuth = await container.read(sessionProvider.notifier).checkAuthStatus();
      final state = container.read(sessionProvider);

      expect(isAuth, true);
      expect(state.isAuthenticated, true);
      expect(state.userRole, isNull);
      expect(GlobalKeys.isValidRole(state.userRole), false);
    });

    test('no token results in unauthenticated session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isAuth = await container.read(sessionProvider.notifier).checkAuthStatus();
      final state = container.read(sessionProvider);

      expect(isAuth, false);
      expect(state.isAuthenticated, false);
      expect(state.userRole, isNull);
    });
  });
}
