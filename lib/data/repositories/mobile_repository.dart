import '../models/mobile_models.dart';
import '../services/api_service.dart';

class MobileRepository {
  final ApiService api;
  MobileRepository(this.api);
  Future<Json> call(
    String method,
    String path, {
    Json? body,
    Json? query,
  }) async {
    final response = await api.request(
      method,
      path,
      data: body,
      queryParameters: query,
    );
    return Json.from(response.data);
  }

  Future<Json> object(String path, {Json? query}) async =>
      Json.from((await call('GET', path, query: query))['data'] ?? {});
  Future<PageData<Monastery>> monasteries({
    String keyword = '',
    bool mine = false,
    int page = 1,
  }) async {
    final path = mine
        ? '/api/v1/monasteries/mine'
        : keyword.trim().isEmpty
        ? '/api/v1/monasteries'
        : '/api/v1/monasteries/search';
    return PageData.fromJson(
      await call(
        'GET',
        path,
        query: {
          'pageNumber': page,
          'pageSize': 10,
          if (!mine && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
        },
      ),
      Monastery.fromJson,
    );
  }

  Future<List<Monastery>> allMine() async {
    final items = <Monastery>[];
    var page = 1;
    while (true) {
      final result = await monasteries(mine: true, page: page++);
      items.addAll(result.items);
      if (!result.hasNext) return items;
    }
  }

  Future<PageData<Donation>> donations({
    int page = 1,
    int? monasteryId,
    int? donorId,
    int? status,
  }) async => PageData.fromJson(
    await call(
      'GET',
      '/api/v1/donations',
      query: {
        'pageNumber': page,
        'pageSize': 10,
        'monasterySpaceId': ?monasteryId,
        'donorId': ?donorId,
        'status': ?status,
      },
    ),
    Donation.fromJson,
  );
  Future<CalendarSummary> calendar(
    DateTime month, {
    int? monasteryId,
    int? status,
  }) async => CalendarSummary.fromJson(
    await object(
      '/api/v1/donations/calendar',
      query: {
        'year': month.year,
        'month': month.month,
        'monasterySpaceId': ?monasteryId,
        'status': ?status,
      },
    ),
  );
  Future<PageData<Json>> list(String path, {int page = 1}) async =>
      PageData.fromJson(
        await call('GET', path, query: {'pageNumber': page, 'pageSize': 10}),
        (json) => json,
      );
  Future<void> donate(
    Json body, {
    bool manual = false,
    bool recurring = false,
  }) async {
    await call(
      'POST',
      '/api/v1/donations/${recurring ? 'recurring/' : ''}${manual ? 'manual' : 'request'}',
      body: body,
    );
  }

  Future<void> donationAction(int id, String action, {Json? body}) async {
    await call(
      action == 'delete' ? 'DELETE' : 'PUT',
      '/api/v1/donations/$id${action == 'delete' ? '' : '/$action'}',
      body: body,
    );
  }

  Future<void> notification(int id, int userId, {bool delete = false}) async {
    await call(
      delete ? 'DELETE' : 'PUT',
      '/api/v1/notifications/${delete ? 'delete' : 'read-noti'}',
      body: {'notificationId': id, 'userId': userId},
    );
  }
}
