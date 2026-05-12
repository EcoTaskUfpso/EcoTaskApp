import 'package:flutter/material.dart';
import 'dart:async';

class AutoDismissDialog extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AutoDismissDialog({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AutoDismissDialog> createState() => _AutoDismissDialogState();
}

class _AutoDismissDialogState extends State<AutoDismissDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoDismiss();
  }

  void _startAutoDismiss() {
    _timer = Timer(widget.duration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: widget.child,
    );
  }
}
