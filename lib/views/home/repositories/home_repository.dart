abstract class HomeRepository {
  Future<int> getUnreadNotificationCount();
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<int> getUnreadNotificationCount() async {
    return 0;
  }
}
