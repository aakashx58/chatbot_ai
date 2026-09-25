import 'package:flutter/material.dart';

import '../../utils/context_extensions.dart';

/// The single page shell every screen uses, so layout rules live in one place:
///
/// * consistent app bar (title + optional subtitle, actions, back button)
/// * body constrained to [maxContentWidth] and centred on tablets/desktop
/// * optional [bottomBar] pinned above the keyboard (e.g. a chat input)
/// * SafeArea handling
///
/// ```dart
/// AppScaffold(
///   title: 'Settings',
///   body: ListView(...),
/// )
/// ```
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.actions = const [],
    this.floatingActionButton,
    this.bottomBar,
    this.header,
    this.maxContentWidth = defaultMaxContentWidth,
    this.showAppBar = true,
    super.key,
  }) : assert(title == null || titleWidget == null, 'Use title or titleWidget, not both');

  static const defaultMaxContentWidth = 760.0;

  final Widget body;
  final String? title;

  /// Custom title (e.g. one driven by a BlocSelector). Overrides [title].
  final Widget? titleWidget;

  /// Small secondary line under the title.
  final Widget? subtitle;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  /// Pinned under the body (moves up with the keyboard).
  final Widget? bottomBar;

  /// Non-scrolling content above the body (e.g. a banner).
  final Widget? header;
  final double maxContentWidth;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? _buildAppBar(context) : null,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: !showAppBar,
        bottom: bottomBar == null,
        child: Column(
          children: [
            if (header != null) _constrained(header!),
            Expanded(child: _constrained(body)),
            if (bottomBar != null) _constrained(bottomBar!),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final titleContent = titleWidget ?? (title == null ? null : Text(title!, overflow: TextOverflow.ellipsis));
    return AppBar(
      title: subtitle == null
          ? titleContent
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?titleContent,
                DefaultTextStyle.merge(
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  child: subtitle!,
                ),
              ],
            ),
      actions: [...actions, const SizedBox(width: 4)],
    );
  }

  Widget _constrained(Widget child) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: child,
    ),
  );
}
