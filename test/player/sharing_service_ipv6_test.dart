import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/sharing/sharing_service.dart';

void main() {
  group('IPv6 formatHostForUrl', () {
    test('formats IPv4 address without brackets', () {
      expect(formatHostForUrl('192.168.1.100'), equals('192.168.1.100'));
      expect(formatHostForUrl('127.0.0.1'), equals('127.0.0.1'));
    });

    test('formats IPv6 address with brackets', () {
      expect(formatHostForUrl('fe80::1'), equals('[fe80::1]'));
      expect(formatHostForUrl('2001:db8::1'), equals('[2001:db8::1]'));
      expect(formatHostForUrl('::1'), equals('[::1]'));
    });

    test('does not add double brackets if IPv6 is already enclosed', () {
      expect(formatHostForUrl('[fe80::1]'), equals('[fe80::1]'));
      expect(formatHostForUrl('[2001:db8::1]'), equals('[2001:db8::1]'));
    });

    test('handles standard hostnames without brackets', () {
      expect(formatHostForUrl('localhost'), equals('localhost'));
      expect(formatHostForUrl('my-pc.local'), equals('my-pc.local'));
    });
  });
}
