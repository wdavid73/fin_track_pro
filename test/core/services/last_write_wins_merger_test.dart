import 'package:fin_track_pro/core/services/last_write_wins_merger.dart';
import 'package:flutter_test/flutter_test.dart';

class _Item {
  final String id;
  final DateTime updatedAt;

  const _Item(this.id, this.updatedAt);
}

void main() {
  group('LastWriteWinsMerger', () {
    MergeResult<_Item> merge(List<_Item> local, List<_Item> remote) {
      return LastWriteWinsMerger.merge<_Item>(
        local: local,
        remote: remote,
        idOf: (item) => item.id,
        updatedAtOf: (item) => item.updatedAt,
      );
    }

    test('item only present locally is queued for upload', () {
      final local = [_Item('1', DateTime(2026))];

      final result = merge(local, []);

      expect(result.toUploadRemote, local);
      expect(result.toSaveLocally, isEmpty);
    });

    test('item only present remotely is queued to save locally', () {
      final remote = [_Item('1', DateTime(2026))];

      final result = merge([], remote);

      expect(result.toSaveLocally, remote);
      expect(result.toUploadRemote, isEmpty);
    });

    test('remote newer than local wins and is saved locally', () {
      final local = [_Item('1', DateTime(2026, 1, 1))];
      final remote = [_Item('1', DateTime(2026, 1, 2))];

      final result = merge(local, remote);

      expect(result.toSaveLocally, [remote.single]);
      expect(result.toUploadRemote, isEmpty);
    });

    test('local newer than remote wins and is uploaded', () {
      final local = [_Item('1', DateTime(2026, 1, 2))];
      final remote = [_Item('1', DateTime(2026, 1, 1))];

      final result = merge(local, remote);

      expect(result.toUploadRemote, [local.single]);
      expect(result.toSaveLocally, isEmpty);
    });

    test('equal updatedAt is a no-op', () {
      final timestamp = DateTime(2026, 1, 1);
      final local = [_Item('1', timestamp)];
      final remote = [_Item('1', timestamp)];

      final result = merge(local, remote);

      expect(result.toSaveLocally, isEmpty);
      expect(result.toUploadRemote, isEmpty);
    });

    test('mixed collections are merged independently per id', () {
      final local = [
        _Item('local-only', DateTime(2026, 1, 1)),
        _Item('local-newer', DateTime(2026, 1, 5)),
        _Item('remote-newer', DateTime(2026, 1, 1)),
      ];
      final remote = [
        _Item('remote-only', DateTime(2026, 1, 1)),
        _Item('local-newer', DateTime(2026, 1, 1)),
        _Item('remote-newer', DateTime(2026, 1, 5)),
      ];

      final result = merge(local, remote);

      expect(
        result.toUploadRemote.map((e) => e.id),
        containsAll(['local-only', 'local-newer']),
      );
      expect(
        result.toSaveLocally.map((e) => e.id),
        containsAll(['remote-only', 'remote-newer']),
      );
    });
  });
}
