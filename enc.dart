import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/pointycastle.dart';

// A class that consists of the methods to encrypt and decrypt the messages.
// Using the AES and a Key length long as the RSA.
class MyEncryptionDecryption {
  static final String password = generateRandomPassword(12);

  // Generate an RSA key pair
  AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
    final random = FortunaRandom();
    final rsaParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);
    final rsaKeyGenerator = RSAKeyGenerator()
      ..init(ParametersWithRandom(rsaParams, random));
    return rsaKeyGenerator.generateKeyPair();
  }

    // Encrypt a string using AES
  String encryptStringAES(String plaintext, String password) {
    final key = encrypt.Key.fromUtf8(password);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return encrypted.base64;
  }
  
  // Encrypt the AES key with RSA
  String encryptAESKeyWithRSA(String aesKey, RSAPublicKey publicKey) {
    final encryptor = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    final encryptedAESKey = encryptor.encrypt(aesKey);
    return encryptedAESKey.base64;
  }

  // Decrypt the AES key with RSA
  String decryptAESKeyWithRSA(String encryptedAESKey, RSAPrivateKey privateKey) {
    final encryptor = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    final encrypted = encrypt.Encrypted.fromBase64(encryptedAESKey);
    final decryptedAESKey = encryptor.decrypt(encrypted);
    return decryptedAESKey;
  }

  // Decrypt a string using AES
  String decryptStringAES(String ciphertext, String password) {
    final key = encrypt.Key.fromUtf8(password);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypt.Encrypted.fromBase64(ciphertext);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

// A method to generate a Random Password.
String generateRandomPassword(int length) {
  final random = Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(255));
  return base64Url.encode(values);
}
