import 'package:flutter/material.dart';

/// 限制滚动距离的ScrollController
/// 限制下拉和上拉距离最多为一指（约50-60像素）
class LimitedScrollController extends ScrollController {
  static const double _maxPullDistance = 60.0; // 最大下拉/上拉距离（像素）
  
  LimitedScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    position.addListener(_onScrollChanged);
  }

  @override
  void detach(ScrollPosition position) {
    position.removeListener(_onScrollChanged);
    super.detach(position);
  }

  void _onScrollChanged() {
    final position = this.position;
    if (!position.hasContentDimensions) return;

    // 检查是否超出最大下拉距离
    if (position.pixels < -_maxPullDistance) {
      position.jumpTo(-_maxPullDistance);
    }
    
    // 检查是否超出最大上拉距离
    final maxScrollExtent = position.maxScrollExtent;
    if (position.pixels > maxScrollExtent + _maxPullDistance) {
      position.jumpTo(maxScrollExtent + _maxPullDistance);
    }
  }
}

/// 限制滚动距离的RefreshIndicator
/// 限制下拉刷新距离最多为一指
class LimitedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final String? semanticsLabel;
  final String? semanticsValue;

  const LimitedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.semanticsLabel,
    this.semanticsValue,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          // 限制下拉距离
          if (notification is ScrollUpdateNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels < -LimitedScrollController._maxPullDistance) {
              // 阻止继续下拉
              return true;
            }
          }
          return false;
        },
        child: child,
      ),
    );
  }
}

/// 限制滚动距离的ListView
/// 限制下拉和上拉距离最多为一指
class LimitedListView extends StatelessWidget {
  final ScrollController? controller;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;

  const LimitedListView({
    super.key,
    this.controller,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final limitedController = controller ?? LimitedScrollController();
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // 限制滚动距离
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          
          // 限制下拉距离
          if (metrics.pixels < -LimitedScrollController._maxPullDistance) {
            return true; // 阻止继续滚动
          }
          
          // 限制上拉距离
          if (metrics.pixels > metrics.maxScrollExtent + LimitedScrollController._maxPullDistance) {
            return true; // 阻止继续滚动
          }
        }
        return false;
      },
      child: ListView(
        controller: limitedController,
        children: children,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        scrollDirection: scrollDirection,
        reverse: reverse,
      ),
    );
  }
}

/// 限制滚动距离的ListView.builder
/// 限制下拉和上拉距离最多为一指
class LimitedListViewBuilder extends StatelessWidget {
  final ScrollController? controller;
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;

  const LimitedListViewBuilder({
    super.key,
    this.controller,
    required this.itemBuilder,
    this.itemCount,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final limitedController = controller ?? LimitedScrollController();
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // 限制滚动距离
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          
          // 限制下拉距离
          if (metrics.pixels < -LimitedScrollController._maxPullDistance) {
            return true; // 阻止继续滚动
          }
          
          // 限制上拉距离
          if (metrics.pixels > metrics.maxScrollExtent + LimitedScrollController._maxPullDistance) {
            return true; // 阻止继续滚动
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: limitedController,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        scrollDirection: scrollDirection,
        reverse: reverse,
      ),
    );
  }
}
