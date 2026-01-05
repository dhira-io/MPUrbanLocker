import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../models/session.dart';

class PKCEUtils {
  static final Random _random = Random.secure();

  /// Generate random bytes
  static Uint8List _generateRandomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  /// Convert bytes to hex string
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Base64 URL encode without padding
  static String _base64UrlEncode(Uint8List bytes) {
    return base64Url
        .encode(bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  /// Generate state (64 hex characters - 32 bytes)
  static String generateState() {
    final bytes = _generateRandomBytes(32);
    return _bytesToHex(bytes);
  }

  /// Generate nonce (32 hex characters - 16 bytes)
  static String generateNonce() {
    final bytes = _generateRandomBytes(16);
    return _bytesToHex(bytes);
  }

  /// Generate code verifier (43-128 characters, base64url encoded)
  static String generateCodeVerifier() {
    final bytes = _generateRandomBytes(32);
    return _base64UrlEncode(bytes);
  }

  /// Generate code challenge from verifier (SHA-256 hash, base64url encoded)
  static String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return _base64UrlEncode(Uint8List.fromList(digest.bytes));
  }

  /// Generate all PKCE parameters
  static PKCEParams generatePKCEParams() {
    final state = generateState();
    final nonce = generateNonce();
    final codeVerifier = generateCodeVerifier();
    final codeChallenge = generateCodeChallenge(codeVerifier);

    return PKCEParams(
      state: state,
      nonce: nonce,
      codeVerifier: codeVerifier,
      codeChallenge: codeChallenge,
    );
  }
}
