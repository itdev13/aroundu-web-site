// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markClosed_lobby_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$markAsClosedLobbyHash() => r'18a1f4be13bae734caa0633e5ba1b3b5f92fe99a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [markAsClosedLobby].
@ProviderFor(markAsClosedLobby)
const markAsClosedLobbyProvider = MarkAsClosedLobbyFamily();

/// See also [markAsClosedLobby].
class MarkAsClosedLobbyFamily extends Family<AsyncValue<bool>> {
  /// See also [markAsClosedLobby].
  const MarkAsClosedLobbyFamily();

  /// See also [markAsClosedLobby].
  MarkAsClosedLobbyProvider call(
    String lobbyId,
  ) {
    return MarkAsClosedLobbyProvider(
      lobbyId,
    );
  }

  @override
  MarkAsClosedLobbyProvider getProviderOverride(
    covariant MarkAsClosedLobbyProvider provider,
  ) {
    return call(
      provider.lobbyId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'markAsClosedLobbyProvider';
}

/// See also [markAsClosedLobby].
class MarkAsClosedLobbyProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [markAsClosedLobby].
  MarkAsClosedLobbyProvider(
    String lobbyId,
  ) : this._internal(
          (ref) => markAsClosedLobby(
            ref as MarkAsClosedLobbyRef,
            lobbyId,
          ),
          from: markAsClosedLobbyProvider,
          name: r'markAsClosedLobbyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markAsClosedLobbyHash,
          dependencies: MarkAsClosedLobbyFamily._dependencies,
          allTransitiveDependencies:
              MarkAsClosedLobbyFamily._allTransitiveDependencies,
          lobbyId: lobbyId,
        );

  MarkAsClosedLobbyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lobbyId,
  }) : super.internal();

  final String lobbyId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(MarkAsClosedLobbyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkAsClosedLobbyProvider._internal(
        (ref) => create(ref as MarkAsClosedLobbyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lobbyId: lobbyId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _MarkAsClosedLobbyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkAsClosedLobbyProvider && other.lobbyId == lobbyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lobbyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarkAsClosedLobbyRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `lobbyId` of this provider.
  String get lobbyId;
}

class _MarkAsClosedLobbyProviderElement
    extends AutoDisposeFutureProviderElement<bool> with MarkAsClosedLobbyRef {
  _MarkAsClosedLobbyProviderElement(super.provider);

  @override
  String get lobbyId => (origin as MarkAsClosedLobbyProvider).lobbyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
