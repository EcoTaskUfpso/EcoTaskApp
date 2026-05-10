import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, render the Google Sign-In button
      return SizedBox(
        width: 52,
        height: 52,
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : _handleWebSignIn,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Semantics(
                label: 'Google',
                button: true,
                child: const FaIcon(FontAwesomeIcons.google),
              ),
        ),
      );
    } else {
      // For mobile platforms
      return SizedBox(
        width: 52,
        height: 52,
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Semantics(
                label: 'Google',
                button: true,
                child: const FaIcon(FontAwesomeIcons.google),
              ),
        ),
      );
    }
  }

  Future<void> _handleWebSignIn() async {
    if (_isDisposed || !mounted) return;
    
    try {
      // For web, we need to use the standard sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (_isDisposed || !mounted) return;
      
      if (googleUser != null && widget.onPressed != null) {
        widget.onPressed!();
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;
      
      // Handle network errors gracefully
      debugPrint('Google Sign-In error: $e');
      
      // Try silent sign-in as fallback
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        
        if (_isDisposed || !mounted) return;
        
        if (googleUser != null && widget.onPressed != null) {
          widget.onPressed!();
        }
      } catch (fallbackError) {
        if (_isDisposed || !mounted) return;
        debugPrint('Google Sign-In fallback error: $fallbackError');
      }
    }
  }
}
