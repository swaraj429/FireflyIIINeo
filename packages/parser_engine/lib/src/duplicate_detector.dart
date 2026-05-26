import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'models/parsed_transaction.dart';
import 'models/raw_sms_input.dart';

class DuplicateDetector {
  /// Generates a unique hash for an SMS message to prevent double processing.
  /// Uses Sender, Amount, and the first 20 characters of the body or full body.
  static String generateHash(RawSmsInput sms, ParsedTransaction? parsed) {
    String baseString = '${sms.sender}_';
    
    if (parsed != null && parsed.amount != null) {
       baseString += '${parsed.amount}_';
    }
    
    // Use a subset of the body to account for minor timestamp variations in carrier SMS
    // but enough to uniquely identify it.
    final bodyClean = sms.body.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final bodyChunk = bodyClean.length > 30 ? bodyClean.substring(0, 30) : bodyClean;
    
    baseString += bodyChunk;
    
    final bytes = utf8.encode(baseString);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
}
