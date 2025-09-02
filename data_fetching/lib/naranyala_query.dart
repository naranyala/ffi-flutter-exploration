import 'package:flutter/widgets.dart';

/// --- Query State ---
class QueryState<T> {
  final T? data;
  final bool isLoading;
  final Object? error;

  const QueryState({this.data, this.isLoading = false, this.error});
}

/// --- Fetcher Type ---
typedef Fetcher<T> = Future<T> Function();

/// --- Global QueryClient ---
class QueryClient {
  static final QueryClient instance = QueryClient._internal();
  QueryClient._internal();

  final Map<String, _CacheItem> _cache = {};

  Query<T> useQuery<T>({
    required String key,
    required Fetcher<T> fetcher,
    Duration cacheTime = const Duration(seconds: 30),
    int retry = 0,
  }) {
    return Query<T>(
      key: key,
      fetcher: fetcher,
      cacheTime: cacheTime,
      retry: retry,
      cache: _cache,
    );
  }

  void invalidate(String key) {
    _cache.remove(key);
  }

  void clearCache() {
    _cache.clear();
  }
}

/// --- Cache Item with TTL ---
class _CacheItem {
  final dynamic data;
  final DateTime expiry;

  _CacheItem({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// --- Query Class ---
class Query<T> extends ChangeNotifier {
  final String key;
  final Fetcher<T> fetcher;
  final Duration cacheTime;
  final int retry;
  final Map<String, _CacheItem> cache;

  QueryState<T> state = const QueryState(isLoading: true);

  Query({
    required this.key,
    required this.fetcher,
    required this.cacheTime,
    required this.retry,
    required this.cache,
  }) {
    _fetch();
  }

  Future<void> _fetch() async {
    // Check cache first
    final cached = cache[key];
    if (cached != null && !cached.isExpired) {
      state = QueryState(data: cached.data);
      notifyListeners();
      return;
    }

    state = const QueryState(isLoading: true);
    notifyListeners();

    int attempts = 0;
    while (true) {
      try {
        final data = await fetcher();
        cache[key] = _CacheItem(
          data: data,
          expiry: DateTime.now().add(cacheTime),
        );
        state = QueryState(data: data);
        notifyListeners();
        return;
      } catch (e) {
        attempts++;
        if (attempts > retry) {
          state = QueryState(error: e);
          notifyListeners();
          return;
        }
        await Future.delayed(const Duration(milliseconds: 500)); // Backoff
      }
    }
  }

  Future<void> refetch() async {
    cache.remove(key); // Force network call
    await _fetch();
  }

  bool get isLoading => state.isLoading;
  T? get data => state.data;
  Object? get error => state.error;
}

/// --- QueryBuilder Widget ---
class QueryBuilder<T> extends StatelessWidget {
  final Query<T> query;
  final Widget Function(BuildContext, QueryState<T>) builder;

  const QueryBuilder({Key? key, required this.query, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: query,
      builder: (context, _) => builder(context, query.state),
    );
  }
}

