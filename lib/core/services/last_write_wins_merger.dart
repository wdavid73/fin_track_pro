/// Result of merging a local and remote collection by Last-Write-Wins.
class MergeResult<T> {
  final List<T> toSaveLocally;
  final List<T> toUploadRemote;

  const MergeResult({required this.toSaveLocally, required this.toUploadRemote});
}

/// Pure Last-Write-Wins merge, keyed by id and compared by `updatedAt`.
///
/// - Present only locally -> goes to `toUploadRemote`.
/// - Present only remotely -> goes to `toSaveLocally`.
/// - Present in both -> the newer `updatedAt` wins; a tie is a no-op.
class LastWriteWinsMerger {
  static MergeResult<T> merge<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) idOf,
    required DateTime Function(T) updatedAtOf,
  }) {
    final localById = {for (final item in local) idOf(item): item};
    final remoteById = {for (final item in remote) idOf(item): item};

    final toSaveLocally = <T>[];
    final toUploadRemote = <T>[];

    for (final id in {...localById.keys, ...remoteById.keys}) {
      final localItem = localById[id];
      final remoteItem = remoteById[id];

      if (localItem == null && remoteItem != null) {
        toSaveLocally.add(remoteItem);
      } else if (localItem != null && remoteItem == null) {
        toUploadRemote.add(localItem);
      } else if (localItem != null && remoteItem != null) {
        final localTime = updatedAtOf(localItem);
        final remoteTime = updatedAtOf(remoteItem);
        if (remoteTime.isAfter(localTime)) {
          toSaveLocally.add(remoteItem);
        } else if (localTime.isAfter(remoteTime)) {
          toUploadRemote.add(localItem);
        }
      }
    }

    return MergeResult(toSaveLocally: toSaveLocally, toUploadRemote: toUploadRemote);
  }
}
