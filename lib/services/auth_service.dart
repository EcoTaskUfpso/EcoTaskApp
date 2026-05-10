import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Ocurrió un error inesperado. Por favor intenta de nuevo.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Ocurrió un error inesperado. Por favor intenta de nuevo.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión. Por favor intenta de nuevo.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Ocurrió un error inesperado. Por favor intenta de nuevo.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For both web and mobile, use the same approach
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      // Handle specific Google Sign-In errors
      if (e.toString().contains('popup_closed') || e.toString().contains('user_cancelled')) {
        throw 'Inicio de sesión cancelado. Por favor intenta de nuevo.';
      } else if (e.toString().contains('network') || e.toString().contains('NetworkError')) {
        throw 'Error de conexión. Verifica tu internet e intenta de nuevo.';
      } else {
        throw 'Error al iniciar sesión con Google. Por favor intenta de nuevo.';
      }
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado. Intenta con otro correo o recupera tu contraseña.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico. Verifica el correo o regístrate.';
      case 'wrong-password':
        return 'La contraseña es incorrecta. Intenta de nuevo o recupera tu contraseña.';
      case 'invalid-email':
        return 'El correo electrónico no es válido. Verifica el formato del correo.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta al administrador.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por favor espera unos minutos antes de intentar nuevamente.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Esta función está deshabilitada temporalmente.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo pero usando otro método de inicio de sesión.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas no son válidas o han expirado.';
      case 'invalid-verification-code':
        return 'El código de verificación no es válido. Verifica e intenta de nuevo.';
      case 'invalid-verification-id':
        return 'El ID de verificación no es válido. Solicita un nuevo código.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet e intenta de nuevo.';
      case 'requires-recent-login':
        return 'Esta operación requiere que inicies sesión nuevamente por seguridad.';
      case 'session-expired':
        return 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
      case 'timeout':
        return 'La operación tardó demasiado tiempo. Verifica tu conexión e intenta de nuevo.';
      default:
        return 'Error de autenticación: ${e.message ?? 'Error desconocido. Por favor intenta de nuevo.'}';
    }
  }
}
