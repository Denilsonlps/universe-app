import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/storage/storage_service.dart';

void main() {
  test('FakeStorageService retorna URL não vazia', () async {
    final s = FakeStorageService();
    final url = await s.uploadContentImage(Uint8List.fromList([1, 2, 3]), ext: 'png');
    expect(url, isNotEmpty);
    expect(url.startsWith('http'), isTrue);
  });
}
