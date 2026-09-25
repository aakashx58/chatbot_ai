import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/context_extensions.dart';

/// Shows a SnackBar whenever [message] of the bloc's state becomes non-null.
///
/// States in this app expose one-off feedback as a nullable `message` that is
/// cleared on the next emit; this widget is the single consumer of that
/// convention (DRY across pages).
class BlocMessageListener<B extends StateStreamable<S>, S> extends StatelessWidget {
  const BlocMessageListener({required this.message, required this.child, super.key});

  final String? Function(S state) message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (_, current) => message(current) != null,
      listener: (context, state) => context.showSnack(message(state)!),
      child: child,
    );
  }
}
