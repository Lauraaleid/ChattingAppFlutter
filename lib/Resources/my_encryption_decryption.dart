import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

//A class that consists of the methods to encrypt and decrypt the messages.
//Using the AES and a Key length long as the RSA.
class MyEncryptionDecryption {
  static final String password = generateRandomPassword(12);

  // Encrypt a string using AES
  String encryptStringAES(String plaintext, String password) {
    final key = Key.fromUtf8(password);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return encrypted.base64;
  }

// Decrypt a string using AES
  String decryptStringAES(String ciphertext, String password) {
    final key = Key.fromUtf8(password);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = Encrypted.fromBase64(ciphertext);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

//A method to generate a Random Password.
String generateRandomPassword(int length) {
  final random = Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(255));
  return base64Url.encode(values);
}
