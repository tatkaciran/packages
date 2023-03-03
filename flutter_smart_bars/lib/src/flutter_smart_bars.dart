import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract class UIBar {
  final Widget? child;
  final double? height;
  final bool? alwaysOn;
  final bool? close;
  final double? speed;
  final bool? autoExpandAtEnd;
  final Widget Function(double scrollDelta, double computedHeight)? build;

  const UIBar({
    this.child,
    this.height,
    this.alwaysOn,
    this.close,
    this.speed,
    this.autoExpandAtEnd,
    this.build,
  });
}

class TopBar extends UIBar {
  const TopBar({
    super.child,
    super.height,
    super.alwaysOn,
    super.close,
    super.speed,
    super.autoExpandAtEnd,
    super.build,
  });

  @override
  bool operator ==(Object other) {
    return other is UIBar &&
        other.child == child &&
        other.height == height &&
        other.alwaysOn == alwaysOn &&
        other.close == close &&
        other.speed == speed &&
        other.autoExpandAtEnd == autoExpandAtEnd &&
        other.build == build &&
        other.hashCode == hashCode;
  }

  @override
  int get hashCode =>
      child.hashCode ^ height.hashCode ^ alwaysOn.hashCode ^ close.hashCode;
}

class BottomBar extends UIBar {
  const BottomBar({
    super.child,
    super.height,
    super.alwaysOn,
    super.close,
    super.speed,
    super.autoExpandAtEnd,
    super.build,
  });

  @override
  bool operator ==(Object other) {
    return other is UIBar &&
        other.child == child &&
        other.height == height &&
        other.alwaysOn == alwaysOn &&
        other.close == close &&
        other.speed == speed &&
        other.autoExpandAtEnd == autoExpandAtEnd &&
        other.build == build &&
        other.hashCode == hashCode;
  }

  @override
  int get hashCode =>
      child.hashCode ^ height.hashCode ^ alwaysOn.hashCode ^ close.hashCode;
}

class SmartBars extends StatefulWidget {
  final Widget? child;
  final TopBar? topBar;
  final BottomBar? bottomBar;
  final bool? closeTopBar;
  final bool? closeBottomBar;

  const SmartBars({
    this.closeTopBar,
    this.closeBottomBar,
    this.topBar,
    this.bottomBar,
    this.child,
    super.key,
  });

  @override
  State<SmartBars> createState() => _SmartBarsState();
}

class _SmartBarsState extends State<SmartBars> {
  final double _fixedHeight = 80;
  final double _fixedSpeed = 0.4;
  final bool _alwaysOff = false;
  double _scrollDelta = 0;
  double _topBarHeight = 80;
  double _bottomBarHeight = 80;
  bool _closeTopBar = false;
  bool _closeBottomBar = false;
  bool _scrollIdle = false;

  @override
  void initState() {
    super.initState();
    _topBarHeight = widget.topBar?.height ?? _fixedHeight;
    _bottomBarHeight = widget.bottomBar?.height ?? _fixedHeight;

    _closeTopBar = widget.closeTopBar ?? _alwaysOff;
    _closeTopBar = widget.topBar?.close ?? _closeTopBar;

    _closeBottomBar = widget.closeBottomBar ?? _alwaysOff;
    _closeBottomBar = widget.bottomBar?.close ?? _closeBottomBar;
  }

  @override
  void didUpdateWidget(covariant SmartBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.closeBottomBar != widget.closeBottomBar;
    oldWidget.closeTopBar != widget.closeTopBar;
    oldWidget.topBar != widget.topBar;
    oldWidget.bottomBar != widget.bottomBar;

    if (oldWidget.topBar != widget.topBar) {
      _topBarHeight = widget.topBar?.height ?? _fixedHeight;
      _closeTopBar = widget.topBar?.close ?? _closeTopBar;
    } else if (oldWidget.topBar == null) {
      _topBarHeight = _fixedHeight;
      _closeTopBar = _alwaysOff;
    }

    if (oldWidget.bottomBar != widget.bottomBar) {
      _bottomBarHeight = widget.bottomBar?.height ?? _fixedHeight;
      _closeBottomBar = widget.bottomBar?.close ?? _closeBottomBar;
    } else if (oldWidget.bottomBar == null) {
      _bottomBarHeight = _fixedHeight;
      _closeBottomBar = _alwaysOff;
    }
  }

  bool _userScrollNotificationOnNotification(
      UserScrollNotification notification) {
    switch (notification.direction) {
      case ScrollDirection.idle:
        _scrollIdle = true;
        break;
      case ScrollDirection.forward:
      case ScrollDirection.reverse:
        _scrollIdle = false;
        break;
    }
    print(_scrollIdle);
    return true;
  }

  bool _scrollUpdateNotificationOnNotification(
    ScrollUpdateNotification notification,
  ) {
    double scrollDelta = notification.scrollDelta ?? 0.0;
    _scrollDelta = scrollDelta;
    bool topBarAtEdge =
        widget.topBar?.autoExpandAtEnd ?? notification.metrics.atEdge;
    bool bottomBarAtEdge =
        widget.bottomBar?.autoExpandAtEnd ?? notification.metrics.atEdge;

    // caculate dynamic height
    _topBarHeight = _topBarHeight -
        (scrollDelta) * ((widget.topBar?.speed ?? _fixedSpeed) * 0.6);
    // if _topBarHeight smaller than zero set zero
    _topBarHeight = _topBarHeight < 0 ? 0 : _topBarHeight;
    // if _topBarHeight bigger than _fixedHeight set_fixedHeight
    _topBarHeight = _topBarHeight > (widget.topBar?.height ?? _fixedHeight)
        ? (widget.topBar?.height ?? _fixedHeight)
        : _topBarHeight;
    // if topBar at end expand
    _topBarHeight =
        topBarAtEdge ? (widget.topBar?.height ?? _fixedHeight) : _topBarHeight;
    // if topBar is allways on keep on
    _topBarHeight = (widget.topBar?.alwaysOn ?? false)
        ? (widget.topBar?.height ?? _fixedHeight)
        : _topBarHeight;

    _bottomBarHeight = _bottomBarHeight +
        (scrollDelta) * ((widget.bottomBar?.speed ?? _fixedSpeed) * 0.5);
    _bottomBarHeight = _bottomBarHeight < 0 ? 0 : _bottomBarHeight;
    _bottomBarHeight =
        _bottomBarHeight > (widget.bottomBar?.height ?? _fixedHeight)
            ? (widget.bottomBar?.height ?? _fixedHeight)
            : _bottomBarHeight;
    _bottomBarHeight = bottomBarAtEdge
        ? (widget.bottomBar?.height ?? _fixedHeight)
        : _bottomBarHeight;
    _bottomBarHeight = (widget.bottomBar?.alwaysOn ?? false)
        ? (widget.bottomBar?.height ?? _fixedHeight)
        : _bottomBarHeight;

    setState(() {});
    return true;
  }

  final List<Widget> _dummyList = List.generate(
    50,
    (i) => Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text("data $i"),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: !_closeTopBar ? _topBarHeight : 0,
          bottom: !_closeBottomBar ? _bottomBarHeight : 0,
          child: NotificationListener<UserScrollNotification>(
            onNotification: _userScrollNotificationOnNotification,
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: _scrollUpdateNotificationOnNotification,
              child: widget.child ??
                  ListView(
                    clipBehavior: Clip.none,
                    cacheExtent: 10,
                    children: _dummyList,
                  ),
            ),
          ),
        ),
        if (!_closeTopBar)
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: _UITopBar(
              height: _topBarHeight,
              child: widget.topBar?.build != null
                  ? widget.topBar?.build!(_scrollDelta, _topBarHeight)
                  : widget.topBar?.child,
            ),
          ),
        if (!_closeBottomBar)
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: _UIBottomBar(
              height: _bottomBarHeight,
              child: widget.bottomBar?.build != null
                  ? widget.bottomBar?.build!(_scrollDelta, _bottomBarHeight)
                  : widget.bottomBar?.child,
            ),
          ),
      ],
    );
  }
}

class _UITopBar extends StatelessWidget {
  final double? height;
  final Widget? child;
  const _UITopBar({
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 80,
      width: double.infinity,
      child: child ?? ColoredBox(color: Colors.blue.withOpacity(.5)),
    );
  }
}

class _UIBottomBar extends StatelessWidget {
  final double? height;
  final Widget? child;
  const _UIBottomBar({
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 80,
      width: double.infinity,
      child: child ?? ColoredBox(color: Colors.blue.withOpacity(.5)),
    );
  }
}
