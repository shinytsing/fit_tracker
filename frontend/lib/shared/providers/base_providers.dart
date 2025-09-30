/// 基础 Provider 类
/// 提供通用的状态管理基类和工具

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_errors.dart';

/// 加载状态枚举
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// 基础状态类
abstract class BaseState {
  final LoadingState loadingState;
  final AppError? error;

  const BaseState({
    required this.loadingState,
    this.error,
  });

  bool get isLoading => loadingState == LoadingState.loading;
  bool get isSuccess => loadingState == LoadingState.success;
  bool get isError => loadingState == LoadingState.error;
  bool get isIdle => loadingState == LoadingState.idle;
}

/// 基础 Provider 类
abstract class BaseProvider<T extends BaseState> extends StateNotifier<T> {
  BaseProvider(super.initialState);

  /// 设置加载状态
  void setLoading() {
    state = _copyWith(loadingState: LoadingState.loading, error: null);
  }

  /// 设置成功状态
  void setSuccess([AppError? error]) {
    state = _copyWith(loadingState: LoadingState.success, error: error);
  }

  /// 设置错误状态
  void setError(AppError error) {
    state = _copyWith(loadingState: LoadingState.error, error: error);
  }

  /// 重置状态
  void reset() {
    state = _copyWith(loadingState: LoadingState.idle, error: null);
  }

  /// 抽象方法，子类需要实现
  T _copyWith({
    LoadingState? loadingState,
    AppError? error,
  });
}

/// 分页状态
class PaginationState {
  final int currentPage;
  final int pageSize;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginationState({
    this.currentPage = 1,
    this.pageSize = 20,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// 分页 Provider 基类
abstract class PaginationProvider<T extends BaseState> extends BaseProvider<T> {
  PaginationProvider(super.initialState);

  PaginationState _paginationState = const PaginationState();

  PaginationState get paginationState => _paginationState;

  /// 加载更多数据
  Future<void> loadMore() async {
    if (!_paginationState.hasMore || _paginationState.isLoadingMore) {
      return;
    }

    _paginationState = _paginationState.copyWith(isLoadingMore: true);
    
    try {
      await loadMoreData();
      _paginationState = _paginationState.copyWith(
        currentPage: _paginationState.currentPage + 1,
        isLoadingMore: false,
      );
    } catch (e) {
      _paginationState = _paginationState.copyWith(isLoadingMore: false);
      setError(UnknownError(message: e.toString()));
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    _paginationState = const PaginationState();
    setLoading();
    
    try {
      await loadData();
      setSuccess();
    } catch (e) {
      setError(UnknownError(message: e.toString()));
    }
  }

  /// 抽象方法，子类需要实现
  Future<void> loadData();
  Future<void> loadMoreData();
}

/// 缓存 Provider 基类
abstract class CacheProvider<T extends BaseState> extends BaseProvider<T> {
  CacheProvider(super.initialState);

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// 获取缓存数据
  T? getCachedData(String key) {
    if (!_cache.containsKey(key)) return null;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;
    
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key] as T?;
  }

  /// 设置缓存数据
  void setCachedData(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 清除缓存
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// 清除特定缓存
  void clearCachedData(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
}