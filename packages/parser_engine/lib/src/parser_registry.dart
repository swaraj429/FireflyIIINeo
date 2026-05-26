import 'models/parsed_transaction.dart';
import 'models/raw_sms_input.dart';
import 'base_parser.dart';
import 'parsers/sbi_parser.dart';
import 'parsers/hdfc_parser.dart';
import 'parsers/icici_parser.dart';
import 'parsers/axis_parser.dart';
import 'parsers/kotak_parser.dart';
import 'parsers/idfc_parser.dart';
import 'parsers/yes_bank_parser.dart';
import 'parsers/pnb_parser.dart';
import 'parsers/upi_parser.dart';
import 'parsers/generic_parser.dart';

class ParserRegistry {
  static final List<BankParser> _parsers = [
    SbiParser(),
    HdfcParser(),
    IciciParser(),
    AxisParser(),
    KotakParser(),
    IdfcParser(),
    YesBankParser(),
    PnbParser(),
    UpiParser(),
    GenericParser(),
  ];

  static ParsedTransaction? parse(RawSmsInput sms) {
    // First try parsers that explicitly claim they can handle the sender
    for (final parser in _parsers) {
      if (parser.canHandle(sms.sender)) {
        final result = parser.parse(sms);
        if (result != null) return result;
      }
    }

    // Fallback: Try all parsers just in case the sender wasn't recognized but the format matches
    for (final parser in _parsers) {
      final result = parser.parse(sms);
      if (result != null) return result;
    }

    return null;
  }
}
