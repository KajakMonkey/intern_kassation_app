import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intern_kassation_app/ui/core/ui/responsive.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
    this.padding,
    this.scrollable = false,
    this.scrollController,
    this.scrollPhysics,
  }) : assert(!scrollable || (scrollable && body != null), 'If scrollable is true, body must not be null'),
       assert(scrollController == null || scrollable, 'If scrollController is provided, scrollable must be true'),
       isLoading = false,
       loadingIndicator = null,
       loadingOverlayColor = null,
       loadingOverlayOpacity = 0.0,
       blockInteraction = false;

  const AppScaffold.withLoadingIndicator({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
    this.padding,
    this.scrollable = false,
    this.scrollController,
    this.scrollPhysics,
    this.isLoading = false,
    this.loadingIndicator,
    this.loadingOverlayColor,
    this.loadingOverlayOpacity = 0.5,
    this.blockInteraction = true,
  }) : assert(!scrollable || (scrollable && body != null), 'If scrollable is true, body must not be null'),
       assert(scrollController == null || scrollable, 'If scrollController is provided, scrollable must be true');

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;

  final bool scrollable;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  final bool isLoading;
  final Widget? loadingIndicator;
  final Color? loadingOverlayColor;
  final double loadingOverlayOpacity;
  final bool blockInteraction;

  static const double _defaultMaxWidth = Responsive.screenMaxWidth;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _defaultMaxWidth),
        child: Padding(
          padding: resolvedPadding,
          child: body,
        ),
      ),
    );

    final Widget scaffoldBody = scrollable
        ? _ScrollableContent(controller: scrollController, physics: scrollPhysics, child: content)
        : content;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color overlayColor =
        loadingOverlayColor?.withValues(alpha: loadingOverlayOpacity) ??
        (isDark
            ? Colors.black.withValues(alpha: loadingOverlayOpacity)
            : Colors.white.withValues(alpha: loadingOverlayOpacity));

    final Widget overlay = isLoading
        ? Positioned.fill(
            child: AbsorbPointer(
              absorbing: blockInteraction,
              child: ColoredBox(
                color: overlayColor,
                child: Center(
                  child: loadingIndicator ?? const CircularProgressIndicator(),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      body: isLoading ? Stack(fit: StackFit.expand, children: [scaffoldBody, overlay]) : scaffoldBody,
    );
  }
}

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({
    required this.child,
    this.controller,
    this.physics,
  });

  final Widget child;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  static final bool _showScrollbar = Platform.isWindows;

  @override
  Widget build(BuildContext context) {
    final ScrollController effectiveController = controller ?? ScrollController();

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: _showScrollbar),
      child: Scrollbar(
        controller: effectiveController,
        thumbVisibility: _showScrollbar,
        child: SingleChildScrollView(
          controller: effectiveController,
          physics: physics ?? const ClampingScrollPhysics(),
          child: child,
        ),
      ),
    );
  }
}
