// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InstalledContentPackagesTable extends InstalledContentPackages
    with TableInfo<$InstalledContentPackagesTable, InstalledContentPackage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledContentPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestHashMeta = const VerificationMeta(
    'manifestHash',
  );
  @override
  late final GeneratedColumn<String> manifestHash = GeneratedColumn<String>(
    'manifest_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageId,
    version,
    schemaVersion,
    manifestHash,
    installedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_content_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledContentPackage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('manifest_hash')) {
      context.handle(
        _manifestHashMeta,
        manifestHash.isAcceptableOrUnknown(
          data['manifest_hash']!,
          _manifestHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestHashMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageId, version};
  @override
  InstalledContentPackage map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledContentPackage(
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      manifestHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_hash'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $InstalledContentPackagesTable createAlias(String alias) {
    return $InstalledContentPackagesTable(attachedDatabase, alias);
  }
}

class InstalledContentPackage extends DataClass
    implements Insertable<InstalledContentPackage> {
  final String packageId;
  final String version;
  final int schemaVersion;
  final String manifestHash;
  final DateTime installedAt;
  final bool isActive;
  const InstalledContentPackage({
    required this.packageId,
    required this.version,
    required this.schemaVersion,
    required this.manifestHash,
    required this.installedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_id'] = Variable<String>(packageId);
    map['version'] = Variable<String>(version);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['manifest_hash'] = Variable<String>(manifestHash);
    map['installed_at'] = Variable<DateTime>(installedAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  InstalledContentPackagesCompanion toCompanion(bool nullToAbsent) {
    return InstalledContentPackagesCompanion(
      packageId: Value(packageId),
      version: Value(version),
      schemaVersion: Value(schemaVersion),
      manifestHash: Value(manifestHash),
      installedAt: Value(installedAt),
      isActive: Value(isActive),
    );
  }

  factory InstalledContentPackage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledContentPackage(
      packageId: serializer.fromJson<String>(json['packageId']),
      version: serializer.fromJson<String>(json['version']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      manifestHash: serializer.fromJson<String>(json['manifestHash']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageId': serializer.toJson<String>(packageId),
      'version': serializer.toJson<String>(version),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'manifestHash': serializer.toJson<String>(manifestHash),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  InstalledContentPackage copyWith({
    String? packageId,
    String? version,
    int? schemaVersion,
    String? manifestHash,
    DateTime? installedAt,
    bool? isActive,
  }) => InstalledContentPackage(
    packageId: packageId ?? this.packageId,
    version: version ?? this.version,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    manifestHash: manifestHash ?? this.manifestHash,
    installedAt: installedAt ?? this.installedAt,
    isActive: isActive ?? this.isActive,
  );
  InstalledContentPackage copyWithCompanion(
    InstalledContentPackagesCompanion data,
  ) {
    return InstalledContentPackage(
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      version: data.version.present ? data.version.value : this.version,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      manifestHash: data.manifestHash.present
          ? data.manifestHash.value
          : this.manifestHash,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledContentPackage(')
          ..write('packageId: $packageId, ')
          ..write('version: $version, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('manifestHash: $manifestHash, ')
          ..write('installedAt: $installedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageId,
    version,
    schemaVersion,
    manifestHash,
    installedAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledContentPackage &&
          other.packageId == this.packageId &&
          other.version == this.version &&
          other.schemaVersion == this.schemaVersion &&
          other.manifestHash == this.manifestHash &&
          other.installedAt == this.installedAt &&
          other.isActive == this.isActive);
}

class InstalledContentPackagesCompanion
    extends UpdateCompanion<InstalledContentPackage> {
  final Value<String> packageId;
  final Value<String> version;
  final Value<int> schemaVersion;
  final Value<String> manifestHash;
  final Value<DateTime> installedAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const InstalledContentPackagesCompanion({
    this.packageId = const Value.absent(),
    this.version = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.manifestHash = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledContentPackagesCompanion.insert({
    required String packageId,
    required String version,
    required int schemaVersion,
    required String manifestHash,
    required DateTime installedAt,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageId = Value(packageId),
       version = Value(version),
       schemaVersion = Value(schemaVersion),
       manifestHash = Value(manifestHash),
       installedAt = Value(installedAt);
  static Insertable<InstalledContentPackage> custom({
    Expression<String>? packageId,
    Expression<String>? version,
    Expression<int>? schemaVersion,
    Expression<String>? manifestHash,
    Expression<DateTime>? installedAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageId != null) 'package_id': packageId,
      if (version != null) 'version': version,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (manifestHash != null) 'manifest_hash': manifestHash,
      if (installedAt != null) 'installed_at': installedAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledContentPackagesCompanion copyWith({
    Value<String>? packageId,
    Value<String>? version,
    Value<int>? schemaVersion,
    Value<String>? manifestHash,
    Value<DateTime>? installedAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return InstalledContentPackagesCompanion(
      packageId: packageId ?? this.packageId,
      version: version ?? this.version,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      manifestHash: manifestHash ?? this.manifestHash,
      installedAt: installedAt ?? this.installedAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (manifestHash.present) {
      map['manifest_hash'] = Variable<String>(manifestHash.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledContentPackagesCompanion(')
          ..write('packageId: $packageId, ')
          ..write('version: $version, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('manifestHash: $manifestHash, ')
          ..write('installedAt: $installedAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressEntriesTable extends LessonProgressEntries
    with TableInfo<$LessonProgressEntriesTable, LessonProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(const ['not_started', 'in_progress', 'completed']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    check: () => score.isNull() | ComparableExpr(score).isBetweenValues(0, 100),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lessonId,
    status,
    score,
    startedAt,
    completedAt,
    contentVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  LessonProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressEntry(
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LessonProgressEntriesTable createAlias(String alias) {
    return $LessonProgressEntriesTable(attachedDatabase, alias);
  }
}

class LessonProgressEntry extends DataClass
    implements Insertable<LessonProgressEntry> {
  final String lessonId;
  final String status;
  final int? score;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String contentVersion;
  final DateTime updatedAt;
  const LessonProgressEntry({
    required this.lessonId,
    required this.status,
    this.score,
    this.startedAt,
    this.completedAt,
    required this.contentVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['content_version'] = Variable<String>(contentVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LessonProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressEntriesCompanion(
      lessonId: Value(lessonId),
      status: Value(status),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      contentVersion: Value(contentVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory LessonProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressEntry(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      status: serializer.fromJson<String>(json['status']),
      score: serializer.fromJson<int?>(json['score']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      contentVersion: serializer.fromJson<String>(json['contentVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'status': serializer.toJson<String>(status),
      'score': serializer.toJson<int?>(score),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'contentVersion': serializer.toJson<String>(contentVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LessonProgressEntry copyWith({
    String? lessonId,
    String? status,
    Value<int?> score = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    String? contentVersion,
    DateTime? updatedAt,
  }) => LessonProgressEntry(
    lessonId: lessonId ?? this.lessonId,
    status: status ?? this.status,
    score: score.present ? score.value : this.score,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    contentVersion: contentVersion ?? this.contentVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LessonProgressEntry copyWithCompanion(LessonProgressEntriesCompanion data) {
    return LessonProgressEntry(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      status: data.status.present ? data.status.value : this.status,
      score: data.score.present ? data.score.value : this.score,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressEntry(')
          ..write('lessonId: $lessonId, ')
          ..write('status: $status, ')
          ..write('score: $score, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lessonId,
    status,
    score,
    startedAt,
    completedAt,
    contentVersion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressEntry &&
          other.lessonId == this.lessonId &&
          other.status == this.status &&
          other.score == this.score &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.contentVersion == this.contentVersion &&
          other.updatedAt == this.updatedAt);
}

class LessonProgressEntriesCompanion
    extends UpdateCompanion<LessonProgressEntry> {
  final Value<String> lessonId;
  final Value<String> status;
  final Value<int?> score;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String> contentVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LessonProgressEntriesCompanion({
    this.lessonId = const Value.absent(),
    this.status = const Value.absent(),
    this.score = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressEntriesCompanion.insert({
    required String lessonId,
    required String status,
    this.score = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    required String contentVersion,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId),
       status = Value(status),
       contentVersion = Value(contentVersion),
       updatedAt = Value(updatedAt);
  static Insertable<LessonProgressEntry> custom({
    Expression<String>? lessonId,
    Expression<String>? status,
    Expression<int>? score,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? contentVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (status != null) 'status': status,
      if (score != null) 'score': score,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (contentVersion != null) 'content_version': contentVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressEntriesCompanion copyWith({
    Value<String>? lessonId,
    Value<String>? status,
    Value<int?>? score,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String>? contentVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LessonProgressEntriesCompanion(
      lessonId: lessonId ?? this.lessonId,
      status: status ?? this.status,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      contentVersion: contentVersion ?? this.contentVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressEntriesCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('status: $status, ')
          ..write('score: $score, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MasteryStatesTable extends MasteryStates
    with TableInfo<$MasteryStatesTable, MasteryState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MasteryStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionMeta = const VerificationMeta(
    'dimension',
  );
  @override
  late final GeneratedColumn<String> dimension = GeneratedColumn<String>(
    'dimension',
    aliasedName,
    false,
    check: () =>
        dimension.isIn(const ['meaning', 'listening', 'tone', 'hanzi']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    check: () => ComparableExpr(box).isBetweenValues(0, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    check: () => ComparableExpr(confidence).isBetweenValues(0, 1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastResultMeta = const VerificationMeta(
    'lastResult',
  );
  @override
  late final GeneratedColumn<String> lastResult = GeneratedColumn<String>(
    'last_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sameDayRetryCountMeta = const VerificationMeta(
    'sameDayRetryCount',
  );
  @override
  late final GeneratedColumn<int> sameDayRetryCount = GeneratedColumn<int>(
    'same_day_retry_count',
    aliasedName,
    false,
    check: () => ComparableExpr(sameDayRetryCount).isBetweenValues(0, 2),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    dimension,
    box,
    confidence,
    dueAt,
    lastResult,
    lastReviewedAt,
    sameDayRetryCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mastery_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<MasteryState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(
        _dimensionMeta,
        dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionMeta);
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    } else if (isInserting) {
      context.missing(_boxMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_result')) {
      context.handle(
        _lastResultMeta,
        lastResult.isAcceptableOrUnknown(data['last_result']!, _lastResultMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('same_day_retry_count')) {
      context.handle(
        _sameDayRetryCountMeta,
        sameDayRetryCount.isAcceptableOrUnknown(
          data['same_day_retry_count']!,
          _sameDayRetryCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, dimension};
  @override
  MasteryState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MasteryState(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      dimension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      lastResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_result'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      sameDayRetryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}same_day_retry_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MasteryStatesTable createAlias(String alias) {
    return $MasteryStatesTable(attachedDatabase, alias);
  }
}

class MasteryState extends DataClass implements Insertable<MasteryState> {
  final String itemId;
  final String dimension;
  final int box;
  final double confidence;
  final DateTime dueAt;
  final String? lastResult;
  final DateTime? lastReviewedAt;
  final int sameDayRetryCount;
  final DateTime updatedAt;
  const MasteryState({
    required this.itemId,
    required this.dimension,
    required this.box,
    required this.confidence,
    required this.dueAt,
    this.lastResult,
    this.lastReviewedAt,
    required this.sameDayRetryCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['dimension'] = Variable<String>(dimension);
    map['box'] = Variable<int>(box);
    map['confidence'] = Variable<double>(confidence);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastResult != null) {
      map['last_result'] = Variable<String>(lastResult);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['same_day_retry_count'] = Variable<int>(sameDayRetryCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MasteryStatesCompanion toCompanion(bool nullToAbsent) {
    return MasteryStatesCompanion(
      itemId: Value(itemId),
      dimension: Value(dimension),
      box: Value(box),
      confidence: Value(confidence),
      dueAt: Value(dueAt),
      lastResult: lastResult == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResult),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      sameDayRetryCount: Value(sameDayRetryCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory MasteryState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MasteryState(
      itemId: serializer.fromJson<String>(json['itemId']),
      dimension: serializer.fromJson<String>(json['dimension']),
      box: serializer.fromJson<int>(json['box']),
      confidence: serializer.fromJson<double>(json['confidence']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastResult: serializer.fromJson<String?>(json['lastResult']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      sameDayRetryCount: serializer.fromJson<int>(json['sameDayRetryCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'dimension': serializer.toJson<String>(dimension),
      'box': serializer.toJson<int>(box),
      'confidence': serializer.toJson<double>(confidence),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastResult': serializer.toJson<String?>(lastResult),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'sameDayRetryCount': serializer.toJson<int>(sameDayRetryCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MasteryState copyWith({
    String? itemId,
    String? dimension,
    int? box,
    double? confidence,
    DateTime? dueAt,
    Value<String?> lastResult = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    int? sameDayRetryCount,
    DateTime? updatedAt,
  }) => MasteryState(
    itemId: itemId ?? this.itemId,
    dimension: dimension ?? this.dimension,
    box: box ?? this.box,
    confidence: confidence ?? this.confidence,
    dueAt: dueAt ?? this.dueAt,
    lastResult: lastResult.present ? lastResult.value : this.lastResult,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    sameDayRetryCount: sameDayRetryCount ?? this.sameDayRetryCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MasteryState copyWithCompanion(MasteryStatesCompanion data) {
    return MasteryState(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      box: data.box.present ? data.box.value : this.box,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastResult: data.lastResult.present
          ? data.lastResult.value
          : this.lastResult,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      sameDayRetryCount: data.sameDayRetryCount.present
          ? data.sameDayRetryCount.value
          : this.sameDayRetryCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MasteryState(')
          ..write('itemId: $itemId, ')
          ..write('dimension: $dimension, ')
          ..write('box: $box, ')
          ..write('confidence: $confidence, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastResult: $lastResult, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('sameDayRetryCount: $sameDayRetryCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    dimension,
    box,
    confidence,
    dueAt,
    lastResult,
    lastReviewedAt,
    sameDayRetryCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MasteryState &&
          other.itemId == this.itemId &&
          other.dimension == this.dimension &&
          other.box == this.box &&
          other.confidence == this.confidence &&
          other.dueAt == this.dueAt &&
          other.lastResult == this.lastResult &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.sameDayRetryCount == this.sameDayRetryCount &&
          other.updatedAt == this.updatedAt);
}

class MasteryStatesCompanion extends UpdateCompanion<MasteryState> {
  final Value<String> itemId;
  final Value<String> dimension;
  final Value<int> box;
  final Value<double> confidence;
  final Value<DateTime> dueAt;
  final Value<String?> lastResult;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> sameDayRetryCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MasteryStatesCompanion({
    this.itemId = const Value.absent(),
    this.dimension = const Value.absent(),
    this.box = const Value.absent(),
    this.confidence = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.sameDayRetryCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MasteryStatesCompanion.insert({
    required String itemId,
    required String dimension,
    required int box,
    required double confidence,
    required DateTime dueAt,
    this.lastResult = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.sameDayRetryCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       dimension = Value(dimension),
       box = Value(box),
       confidence = Value(confidence),
       dueAt = Value(dueAt),
       updatedAt = Value(updatedAt);
  static Insertable<MasteryState> custom({
    Expression<String>? itemId,
    Expression<String>? dimension,
    Expression<int>? box,
    Expression<double>? confidence,
    Expression<DateTime>? dueAt,
    Expression<String>? lastResult,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? sameDayRetryCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (dimension != null) 'dimension': dimension,
      if (box != null) 'box': box,
      if (confidence != null) 'confidence': confidence,
      if (dueAt != null) 'due_at': dueAt,
      if (lastResult != null) 'last_result': lastResult,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (sameDayRetryCount != null) 'same_day_retry_count': sameDayRetryCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MasteryStatesCompanion copyWith({
    Value<String>? itemId,
    Value<String>? dimension,
    Value<int>? box,
    Value<double>? confidence,
    Value<DateTime>? dueAt,
    Value<String?>? lastResult,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? sameDayRetryCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MasteryStatesCompanion(
      itemId: itemId ?? this.itemId,
      dimension: dimension ?? this.dimension,
      box: box ?? this.box,
      confidence: confidence ?? this.confidence,
      dueAt: dueAt ?? this.dueAt,
      lastResult: lastResult ?? this.lastResult,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      sameDayRetryCount: sameDayRetryCount ?? this.sameDayRetryCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<String>(dimension.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastResult.present) {
      map['last_result'] = Variable<String>(lastResult.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (sameDayRetryCount.present) {
      map['same_day_retry_count'] = Variable<int>(sameDayRetryCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MasteryStatesCompanion(')
          ..write('itemId: $itemId, ')
          ..write('dimension: $dimension, ')
          ..write('box: $box, ')
          ..write('confidence: $confidence, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastResult: $lastResult, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('sameDayRetryCount: $sameDayRetryCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewAttemptsTable extends ReviewAttempts
    with TableInfo<$ReviewAttemptsTable, ReviewAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionMeta = const VerificationMeta(
    'dimension',
  );
  @override
  late final GeneratedColumn<String> dimension = GeneratedColumn<String>(
    'dimension',
    aliasedName,
    false,
    check: () =>
        dimension.isIn(const ['meaning', 'listening', 'tone', 'hanzi']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    check: () => result.isIn(const ['forgotten', 'vague', 'remembered']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _usedHintMeta = const VerificationMeta(
    'usedHint',
  );
  @override
  late final GeneratedColumn<bool> usedHint = GeneratedColumn<bool>(
    'used_hint',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("used_hint" IN (0, 1))',
    ),
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    false,
    check: () => ComparableExpr(latencyMs).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attemptId,
    itemId,
    dimension,
    result,
    correct,
    usedHint,
    latencyMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(
        _dimensionMeta,
        dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('used_hint')) {
      context.handle(
        _usedHintMeta,
        usedHint.isAcceptableOrUnknown(data['used_hint']!, _usedHintMeta),
      );
    } else if (isInserting) {
      context.missing(_usedHintMeta);
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
    } else if (isInserting) {
      context.missing(_latencyMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attemptId};
  @override
  ReviewAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewAttempt(
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      dimension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      usedHint: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}used_hint'],
      )!,
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReviewAttemptsTable createAlias(String alias) {
    return $ReviewAttemptsTable(attachedDatabase, alias);
  }
}

class ReviewAttempt extends DataClass implements Insertable<ReviewAttempt> {
  final String attemptId;
  final String itemId;
  final String dimension;
  final String result;
  final bool correct;
  final bool usedHint;
  final int latencyMs;
  final DateTime createdAt;
  const ReviewAttempt({
    required this.attemptId,
    required this.itemId,
    required this.dimension,
    required this.result,
    required this.correct,
    required this.usedHint,
    required this.latencyMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempt_id'] = Variable<String>(attemptId);
    map['item_id'] = Variable<String>(itemId);
    map['dimension'] = Variable<String>(dimension);
    map['result'] = Variable<String>(result);
    map['correct'] = Variable<bool>(correct);
    map['used_hint'] = Variable<bool>(usedHint);
    map['latency_ms'] = Variable<int>(latencyMs);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReviewAttemptsCompanion toCompanion(bool nullToAbsent) {
    return ReviewAttemptsCompanion(
      attemptId: Value(attemptId),
      itemId: Value(itemId),
      dimension: Value(dimension),
      result: Value(result),
      correct: Value(correct),
      usedHint: Value(usedHint),
      latencyMs: Value(latencyMs),
      createdAt: Value(createdAt),
    );
  }

  factory ReviewAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewAttempt(
      attemptId: serializer.fromJson<String>(json['attemptId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      dimension: serializer.fromJson<String>(json['dimension']),
      result: serializer.fromJson<String>(json['result']),
      correct: serializer.fromJson<bool>(json['correct']),
      usedHint: serializer.fromJson<bool>(json['usedHint']),
      latencyMs: serializer.fromJson<int>(json['latencyMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attemptId': serializer.toJson<String>(attemptId),
      'itemId': serializer.toJson<String>(itemId),
      'dimension': serializer.toJson<String>(dimension),
      'result': serializer.toJson<String>(result),
      'correct': serializer.toJson<bool>(correct),
      'usedHint': serializer.toJson<bool>(usedHint),
      'latencyMs': serializer.toJson<int>(latencyMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReviewAttempt copyWith({
    String? attemptId,
    String? itemId,
    String? dimension,
    String? result,
    bool? correct,
    bool? usedHint,
    int? latencyMs,
    DateTime? createdAt,
  }) => ReviewAttempt(
    attemptId: attemptId ?? this.attemptId,
    itemId: itemId ?? this.itemId,
    dimension: dimension ?? this.dimension,
    result: result ?? this.result,
    correct: correct ?? this.correct,
    usedHint: usedHint ?? this.usedHint,
    latencyMs: latencyMs ?? this.latencyMs,
    createdAt: createdAt ?? this.createdAt,
  );
  ReviewAttempt copyWithCompanion(ReviewAttemptsCompanion data) {
    return ReviewAttempt(
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      result: data.result.present ? data.result.value : this.result,
      correct: data.correct.present ? data.correct.value : this.correct,
      usedHint: data.usedHint.present ? data.usedHint.value : this.usedHint,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewAttempt(')
          ..write('attemptId: $attemptId, ')
          ..write('itemId: $itemId, ')
          ..write('dimension: $dimension, ')
          ..write('result: $result, ')
          ..write('correct: $correct, ')
          ..write('usedHint: $usedHint, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attemptId,
    itemId,
    dimension,
    result,
    correct,
    usedHint,
    latencyMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewAttempt &&
          other.attemptId == this.attemptId &&
          other.itemId == this.itemId &&
          other.dimension == this.dimension &&
          other.result == this.result &&
          other.correct == this.correct &&
          other.usedHint == this.usedHint &&
          other.latencyMs == this.latencyMs &&
          other.createdAt == this.createdAt);
}

class ReviewAttemptsCompanion extends UpdateCompanion<ReviewAttempt> {
  final Value<String> attemptId;
  final Value<String> itemId;
  final Value<String> dimension;
  final Value<String> result;
  final Value<bool> correct;
  final Value<bool> usedHint;
  final Value<int> latencyMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReviewAttemptsCompanion({
    this.attemptId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.dimension = const Value.absent(),
    this.result = const Value.absent(),
    this.correct = const Value.absent(),
    this.usedHint = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewAttemptsCompanion.insert({
    required String attemptId,
    required String itemId,
    required String dimension,
    required String result,
    required bool correct,
    required bool usedHint,
    required int latencyMs,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : attemptId = Value(attemptId),
       itemId = Value(itemId),
       dimension = Value(dimension),
       result = Value(result),
       correct = Value(correct),
       usedHint = Value(usedHint),
       latencyMs = Value(latencyMs),
       createdAt = Value(createdAt);
  static Insertable<ReviewAttempt> custom({
    Expression<String>? attemptId,
    Expression<String>? itemId,
    Expression<String>? dimension,
    Expression<String>? result,
    Expression<bool>? correct,
    Expression<bool>? usedHint,
    Expression<int>? latencyMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attemptId != null) 'attempt_id': attemptId,
      if (itemId != null) 'item_id': itemId,
      if (dimension != null) 'dimension': dimension,
      if (result != null) 'result': result,
      if (correct != null) 'correct': correct,
      if (usedHint != null) 'used_hint': usedHint,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewAttemptsCompanion copyWith({
    Value<String>? attemptId,
    Value<String>? itemId,
    Value<String>? dimension,
    Value<String>? result,
    Value<bool>? correct,
    Value<bool>? usedHint,
    Value<int>? latencyMs,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReviewAttemptsCompanion(
      attemptId: attemptId ?? this.attemptId,
      itemId: itemId ?? this.itemId,
      dimension: dimension ?? this.dimension,
      result: result ?? this.result,
      correct: correct ?? this.correct,
      usedHint: usedHint ?? this.usedHint,
      latencyMs: latencyMs ?? this.latencyMs,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<String>(dimension.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (usedHint.present) {
      map['used_hint'] = Variable<bool>(usedHint.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewAttemptsCompanion(')
          ..write('attemptId: $attemptId, ')
          ..write('itemId: $itemId, ')
          ..write('dimension: $dimension, ')
          ..write('result: $result, ')
          ..write('correct: $correct, ')
          ..write('usedHint: $usedHint, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpeakingAttemptsTable extends SpeakingAttempts
    with TableInfo<$SpeakingAttemptsTable, SpeakingAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeakingAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localScoreMeta = const VerificationMeta(
    'localScore',
  );
  @override
  late final GeneratedColumn<double> localScore = GeneratedColumn<double>(
    'local_score',
    aliasedName,
    true,
    check: () =>
        localScore.isNull() | ComparableExpr(localScore).isBetweenValues(0, 1),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerScoreMeta = const VerificationMeta(
    'providerScore',
  );
  @override
  late final GeneratedColumn<double> providerScore = GeneratedColumn<double>(
    'provider_score',
    aliasedName,
    true,
    check: () =>
        providerScore.isNull() |
        ComparableExpr(providerScore).isBetweenValues(0, 1),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attemptId,
    targetId,
    localScore,
    providerScore,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'speaking_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeakingAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('local_score')) {
      context.handle(
        _localScoreMeta,
        localScore.isAcceptableOrUnknown(data['local_score']!, _localScoreMeta),
      );
    }
    if (data.containsKey('provider_score')) {
      context.handle(
        _providerScoreMeta,
        providerScore.isAcceptableOrUnknown(
          data['provider_score']!,
          _providerScoreMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attemptId};
  @override
  SpeakingAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeakingAttempt(
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      localScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}local_score'],
      ),
      providerScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}provider_score'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SpeakingAttemptsTable createAlias(String alias) {
    return $SpeakingAttemptsTable(attachedDatabase, alias);
  }
}

class SpeakingAttempt extends DataClass implements Insertable<SpeakingAttempt> {
  final String attemptId;
  final String targetId;
  final double? localScore;
  final double? providerScore;
  final DateTime createdAt;
  const SpeakingAttempt({
    required this.attemptId,
    required this.targetId,
    this.localScore,
    this.providerScore,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempt_id'] = Variable<String>(attemptId);
    map['target_id'] = Variable<String>(targetId);
    if (!nullToAbsent || localScore != null) {
      map['local_score'] = Variable<double>(localScore);
    }
    if (!nullToAbsent || providerScore != null) {
      map['provider_score'] = Variable<double>(providerScore);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpeakingAttemptsCompanion toCompanion(bool nullToAbsent) {
    return SpeakingAttemptsCompanion(
      attemptId: Value(attemptId),
      targetId: Value(targetId),
      localScore: localScore == null && nullToAbsent
          ? const Value.absent()
          : Value(localScore),
      providerScore: providerScore == null && nullToAbsent
          ? const Value.absent()
          : Value(providerScore),
      createdAt: Value(createdAt),
    );
  }

  factory SpeakingAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeakingAttempt(
      attemptId: serializer.fromJson<String>(json['attemptId']),
      targetId: serializer.fromJson<String>(json['targetId']),
      localScore: serializer.fromJson<double?>(json['localScore']),
      providerScore: serializer.fromJson<double?>(json['providerScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attemptId': serializer.toJson<String>(attemptId),
      'targetId': serializer.toJson<String>(targetId),
      'localScore': serializer.toJson<double?>(localScore),
      'providerScore': serializer.toJson<double?>(providerScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SpeakingAttempt copyWith({
    String? attemptId,
    String? targetId,
    Value<double?> localScore = const Value.absent(),
    Value<double?> providerScore = const Value.absent(),
    DateTime? createdAt,
  }) => SpeakingAttempt(
    attemptId: attemptId ?? this.attemptId,
    targetId: targetId ?? this.targetId,
    localScore: localScore.present ? localScore.value : this.localScore,
    providerScore: providerScore.present
        ? providerScore.value
        : this.providerScore,
    createdAt: createdAt ?? this.createdAt,
  );
  SpeakingAttempt copyWithCompanion(SpeakingAttemptsCompanion data) {
    return SpeakingAttempt(
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      localScore: data.localScore.present
          ? data.localScore.value
          : this.localScore,
      providerScore: data.providerScore.present
          ? data.providerScore.value
          : this.providerScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeakingAttempt(')
          ..write('attemptId: $attemptId, ')
          ..write('targetId: $targetId, ')
          ..write('localScore: $localScore, ')
          ..write('providerScore: $providerScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(attemptId, targetId, localScore, providerScore, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeakingAttempt &&
          other.attemptId == this.attemptId &&
          other.targetId == this.targetId &&
          other.localScore == this.localScore &&
          other.providerScore == this.providerScore &&
          other.createdAt == this.createdAt);
}

class SpeakingAttemptsCompanion extends UpdateCompanion<SpeakingAttempt> {
  final Value<String> attemptId;
  final Value<String> targetId;
  final Value<double?> localScore;
  final Value<double?> providerScore;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SpeakingAttemptsCompanion({
    this.attemptId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.localScore = const Value.absent(),
    this.providerScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeakingAttemptsCompanion.insert({
    required String attemptId,
    required String targetId,
    this.localScore = const Value.absent(),
    this.providerScore = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : attemptId = Value(attemptId),
       targetId = Value(targetId),
       createdAt = Value(createdAt);
  static Insertable<SpeakingAttempt> custom({
    Expression<String>? attemptId,
    Expression<String>? targetId,
    Expression<double>? localScore,
    Expression<double>? providerScore,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attemptId != null) 'attempt_id': attemptId,
      if (targetId != null) 'target_id': targetId,
      if (localScore != null) 'local_score': localScore,
      if (providerScore != null) 'provider_score': providerScore,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeakingAttemptsCompanion copyWith({
    Value<String>? attemptId,
    Value<String>? targetId,
    Value<double?>? localScore,
    Value<double?>? providerScore,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SpeakingAttemptsCompanion(
      attemptId: attemptId ?? this.attemptId,
      targetId: targetId ?? this.targetId,
      localScore: localScore ?? this.localScore,
      providerScore: providerScore ?? this.providerScore,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (localScore.present) {
      map['local_score'] = Variable<double>(localScore.value);
    }
    if (providerScore.present) {
      map['provider_score'] = Variable<double>(providerScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeakingAttemptsCompanion(')
          ..write('attemptId: $attemptId, ')
          ..write('targetId: $targetId, ')
          ..write('localScore: $localScore, ')
          ..write('providerScore: $providerScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEventsTable extends SyncOutboxEvents
    with TableInfo<$SyncOutboxEventsTable, SyncOutboxEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    check: () => ComparableExpr(attempts).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    entityType,
    payloadJson,
    occurredAt,
    attempts,
    acknowledgedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  SyncOutboxEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      ),
    );
  }

  @override
  $SyncOutboxEventsTable createAlias(String alias) {
    return $SyncOutboxEventsTable(attachedDatabase, alias);
  }
}

class SyncOutboxEvent extends DataClass implements Insertable<SyncOutboxEvent> {
  final String eventId;
  final String entityType;
  final String payloadJson;
  final DateTime occurredAt;
  final int attempts;
  final DateTime? acknowledgedAt;
  const SyncOutboxEvent({
    required this.eventId,
    required this.entityType,
    required this.payloadJson,
    required this.occurredAt,
    required this.attempts,
    this.acknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['entity_type'] = Variable<String>(entityType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || acknowledgedAt != null) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    }
    return map;
  }

  SyncOutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEventsCompanion(
      eventId: Value(eventId),
      entityType: Value(entityType),
      payloadJson: Value(payloadJson),
      occurredAt: Value(occurredAt),
      attempts: Value(attempts),
      acknowledgedAt: acknowledgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAt),
    );
  }

  factory SyncOutboxEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      acknowledgedAt: serializer.fromJson<DateTime?>(json['acknowledgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'entityType': serializer.toJson<String>(entityType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'attempts': serializer.toJson<int>(attempts),
      'acknowledgedAt': serializer.toJson<DateTime?>(acknowledgedAt),
    };
  }

  SyncOutboxEvent copyWith({
    String? eventId,
    String? entityType,
    String? payloadJson,
    DateTime? occurredAt,
    int? attempts,
    Value<DateTime?> acknowledgedAt = const Value.absent(),
  }) => SyncOutboxEvent(
    eventId: eventId ?? this.eventId,
    entityType: entityType ?? this.entityType,
    payloadJson: payloadJson ?? this.payloadJson,
    occurredAt: occurredAt ?? this.occurredAt,
    attempts: attempts ?? this.attempts,
    acknowledgedAt: acknowledgedAt.present
        ? acknowledgedAt.value
        : this.acknowledgedAt,
  );
  SyncOutboxEvent copyWithCompanion(SyncOutboxEventsCompanion data) {
    return SyncOutboxEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEvent(')
          ..write('eventId: $eventId, ')
          ..write('entityType: $entityType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('attempts: $attempts, ')
          ..write('acknowledgedAt: $acknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    entityType,
    payloadJson,
    occurredAt,
    attempts,
    acknowledgedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEvent &&
          other.eventId == this.eventId &&
          other.entityType == this.entityType &&
          other.payloadJson == this.payloadJson &&
          other.occurredAt == this.occurredAt &&
          other.attempts == this.attempts &&
          other.acknowledgedAt == this.acknowledgedAt);
}

class SyncOutboxEventsCompanion extends UpdateCompanion<SyncOutboxEvent> {
  final Value<String> eventId;
  final Value<String> entityType;
  final Value<String> payloadJson;
  final Value<DateTime> occurredAt;
  final Value<int> attempts;
  final Value<DateTime?> acknowledgedAt;
  final Value<int> rowid;
  const SyncOutboxEventsCompanion({
    this.eventId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxEventsCompanion.insert({
    required String eventId,
    required String entityType,
    required String payloadJson,
    required DateTime occurredAt,
    this.attempts = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       entityType = Value(entityType),
       payloadJson = Value(payloadJson),
       occurredAt = Value(occurredAt);
  static Insertable<SyncOutboxEvent> custom({
    Expression<String>? eventId,
    Expression<String>? entityType,
    Expression<String>? payloadJson,
    Expression<DateTime>? occurredAt,
    Expression<int>? attempts,
    Expression<DateTime>? acknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (entityType != null) 'entity_type': entityType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (attempts != null) 'attempts': attempts,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? entityType,
    Value<String>? payloadJson,
    Value<DateTime>? occurredAt,
    Value<int>? attempts,
    Value<DateTime?>? acknowledgedAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxEventsCompanion(
      eventId: eventId ?? this.eventId,
      entityType: entityType ?? this.entityType,
      payloadJson: payloadJson ?? this.payloadJson,
      occurredAt: occurredAt ?? this.occurredAt,
      attempts: attempts ?? this.attempts,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('entityType: $entityType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('attempts: $attempts, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstalledContentPackagesTable installedContentPackages =
      $InstalledContentPackagesTable(this);
  late final $LessonProgressEntriesTable lessonProgressEntries =
      $LessonProgressEntriesTable(this);
  late final $MasteryStatesTable masteryStates = $MasteryStatesTable(this);
  late final $ReviewAttemptsTable reviewAttempts = $ReviewAttemptsTable(this);
  late final $SpeakingAttemptsTable speakingAttempts = $SpeakingAttemptsTable(
    this,
  );
  late final $SyncOutboxEventsTable syncOutboxEvents = $SyncOutboxEventsTable(
    this,
  );
  late final Index masteryStatesDueAt = Index(
    'mastery_states_due_at',
    'CREATE INDEX mastery_states_due_at ON mastery_states (due_at)',
  );
  late final Index reviewAttemptsItemCreatedAt = Index(
    'review_attempts_item_created_at',
    'CREATE INDEX review_attempts_item_created_at ON review_attempts (item_id, created_at)',
  );
  late final Index syncOutboxOccurredAt = Index(
    'sync_outbox_occurred_at',
    'CREATE INDEX sync_outbox_occurred_at ON sync_outbox_events (occurred_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    installedContentPackages,
    lessonProgressEntries,
    masteryStates,
    reviewAttempts,
    speakingAttempts,
    syncOutboxEvents,
    masteryStatesDueAt,
    reviewAttemptsItemCreatedAt,
    syncOutboxOccurredAt,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$InstalledContentPackagesTableCreateCompanionBuilder =
    InstalledContentPackagesCompanion Function({
      required String packageId,
      required String version,
      required int schemaVersion,
      required String manifestHash,
      required DateTime installedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$InstalledContentPackagesTableUpdateCompanionBuilder =
    InstalledContentPackagesCompanion Function({
      Value<String> packageId,
      Value<String> version,
      Value<int> schemaVersion,
      Value<String> manifestHash,
      Value<DateTime> installedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$InstalledContentPackagesTableFilterComposer
    extends Composer<_$AppDatabase, $InstalledContentPackagesTable> {
  $$InstalledContentPackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestHash => $composableBuilder(
    column: $table.manifestHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledContentPackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalledContentPackagesTable> {
  $$InstalledContentPackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestHash => $composableBuilder(
    column: $table.manifestHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledContentPackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalledContentPackagesTable> {
  $$InstalledContentPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manifestHash => $composableBuilder(
    column: $table.manifestHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$InstalledContentPackagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalledContentPackagesTable,
          InstalledContentPackage,
          $$InstalledContentPackagesTableFilterComposer,
          $$InstalledContentPackagesTableOrderingComposer,
          $$InstalledContentPackagesTableAnnotationComposer,
          $$InstalledContentPackagesTableCreateCompanionBuilder,
          $$InstalledContentPackagesTableUpdateCompanionBuilder,
          (
            InstalledContentPackage,
            BaseReferences<
              _$AppDatabase,
              $InstalledContentPackagesTable,
              InstalledContentPackage
            >,
          ),
          InstalledContentPackage,
          PrefetchHooks Function()
        > {
  $$InstalledContentPackagesTableTableManager(
    _$AppDatabase db,
    $InstalledContentPackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledContentPackagesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InstalledContentPackagesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstalledContentPackagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> packageId = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> manifestHash = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledContentPackagesCompanion(
                packageId: packageId,
                version: version,
                schemaVersion: schemaVersion,
                manifestHash: manifestHash,
                installedAt: installedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageId,
                required String version,
                required int schemaVersion,
                required String manifestHash,
                required DateTime installedAt,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledContentPackagesCompanion.insert(
                packageId: packageId,
                version: version,
                schemaVersion: schemaVersion,
                manifestHash: manifestHash,
                installedAt: installedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledContentPackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalledContentPackagesTable,
      InstalledContentPackage,
      $$InstalledContentPackagesTableFilterComposer,
      $$InstalledContentPackagesTableOrderingComposer,
      $$InstalledContentPackagesTableAnnotationComposer,
      $$InstalledContentPackagesTableCreateCompanionBuilder,
      $$InstalledContentPackagesTableUpdateCompanionBuilder,
      (
        InstalledContentPackage,
        BaseReferences<
          _$AppDatabase,
          $InstalledContentPackagesTable,
          InstalledContentPackage
        >,
      ),
      InstalledContentPackage,
      PrefetchHooks Function()
    >;
typedef $$LessonProgressEntriesTableCreateCompanionBuilder =
    LessonProgressEntriesCompanion Function({
      required String lessonId,
      required String status,
      Value<int?> score,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      required String contentVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LessonProgressEntriesTableUpdateCompanionBuilder =
    LessonProgressEntriesCompanion Function({
      Value<String> lessonId,
      Value<String> status,
      Value<int?> score,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String> contentVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LessonProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressEntriesTable> {
  $$LessonProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressEntriesTable> {
  $$LessonProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressEntriesTable> {
  $$LessonProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LessonProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressEntriesTable,
          LessonProgressEntry,
          $$LessonProgressEntriesTableFilterComposer,
          $$LessonProgressEntriesTableOrderingComposer,
          $$LessonProgressEntriesTableAnnotationComposer,
          $$LessonProgressEntriesTableCreateCompanionBuilder,
          $$LessonProgressEntriesTableUpdateCompanionBuilder,
          (
            LessonProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $LessonProgressEntriesTable,
              LessonProgressEntry
            >,
          ),
          LessonProgressEntry,
          PrefetchHooks Function()
        > {
  $$LessonProgressEntriesTableTableManager(
    _$AppDatabase db,
    $LessonProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LessonProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LessonProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> lessonId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> contentVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressEntriesCompanion(
                lessonId: lessonId,
                status: status,
                score: score,
                startedAt: startedAt,
                completedAt: completedAt,
                contentVersion: contentVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lessonId,
                required String status,
                Value<int?> score = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required String contentVersion,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressEntriesCompanion.insert(
                lessonId: lessonId,
                status: status,
                score: score,
                startedAt: startedAt,
                completedAt: completedAt,
                contentVersion: contentVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressEntriesTable,
      LessonProgressEntry,
      $$LessonProgressEntriesTableFilterComposer,
      $$LessonProgressEntriesTableOrderingComposer,
      $$LessonProgressEntriesTableAnnotationComposer,
      $$LessonProgressEntriesTableCreateCompanionBuilder,
      $$LessonProgressEntriesTableUpdateCompanionBuilder,
      (
        LessonProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $LessonProgressEntriesTable,
          LessonProgressEntry
        >,
      ),
      LessonProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$MasteryStatesTableCreateCompanionBuilder =
    MasteryStatesCompanion Function({
      required String itemId,
      required String dimension,
      required int box,
      required double confidence,
      required DateTime dueAt,
      Value<String?> lastResult,
      Value<DateTime?> lastReviewedAt,
      Value<int> sameDayRetryCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MasteryStatesTableUpdateCompanionBuilder =
    MasteryStatesCompanion Function({
      Value<String> itemId,
      Value<String> dimension,
      Value<int> box,
      Value<double> confidence,
      Value<DateTime> dueAt,
      Value<String?> lastResult,
      Value<DateTime?> lastReviewedAt,
      Value<int> sameDayRetryCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MasteryStatesTableFilterComposer
    extends Composer<_$AppDatabase, $MasteryStatesTable> {
  $$MasteryStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sameDayRetryCount => $composableBuilder(
    column: $table.sameDayRetryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MasteryStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MasteryStatesTable> {
  $$MasteryStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sameDayRetryCount => $composableBuilder(
    column: $table.sameDayRetryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MasteryStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MasteryStatesTable> {
  $$MasteryStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sameDayRetryCount => $composableBuilder(
    column: $table.sameDayRetryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MasteryStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MasteryStatesTable,
          MasteryState,
          $$MasteryStatesTableFilterComposer,
          $$MasteryStatesTableOrderingComposer,
          $$MasteryStatesTableAnnotationComposer,
          $$MasteryStatesTableCreateCompanionBuilder,
          $$MasteryStatesTableUpdateCompanionBuilder,
          (
            MasteryState,
            BaseReferences<_$AppDatabase, $MasteryStatesTable, MasteryState>,
          ),
          MasteryState,
          PrefetchHooks Function()
        > {
  $$MasteryStatesTableTableManager(_$AppDatabase db, $MasteryStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MasteryStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MasteryStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MasteryStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> dimension = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<String?> lastResult = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> sameDayRetryCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MasteryStatesCompanion(
                itemId: itemId,
                dimension: dimension,
                box: box,
                confidence: confidence,
                dueAt: dueAt,
                lastResult: lastResult,
                lastReviewedAt: lastReviewedAt,
                sameDayRetryCount: sameDayRetryCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String dimension,
                required int box,
                required double confidence,
                required DateTime dueAt,
                Value<String?> lastResult = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> sameDayRetryCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MasteryStatesCompanion.insert(
                itemId: itemId,
                dimension: dimension,
                box: box,
                confidence: confidence,
                dueAt: dueAt,
                lastResult: lastResult,
                lastReviewedAt: lastReviewedAt,
                sameDayRetryCount: sameDayRetryCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MasteryStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MasteryStatesTable,
      MasteryState,
      $$MasteryStatesTableFilterComposer,
      $$MasteryStatesTableOrderingComposer,
      $$MasteryStatesTableAnnotationComposer,
      $$MasteryStatesTableCreateCompanionBuilder,
      $$MasteryStatesTableUpdateCompanionBuilder,
      (
        MasteryState,
        BaseReferences<_$AppDatabase, $MasteryStatesTable, MasteryState>,
      ),
      MasteryState,
      PrefetchHooks Function()
    >;
typedef $$ReviewAttemptsTableCreateCompanionBuilder =
    ReviewAttemptsCompanion Function({
      required String attemptId,
      required String itemId,
      required String dimension,
      required String result,
      required bool correct,
      required bool usedHint,
      required int latencyMs,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReviewAttemptsTableUpdateCompanionBuilder =
    ReviewAttemptsCompanion Function({
      Value<String> attemptId,
      Value<String> itemId,
      Value<String> dimension,
      Value<String> result,
      Value<bool> correct,
      Value<bool> usedHint,
      Value<int> latencyMs,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ReviewAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewAttemptsTable> {
  $$ReviewAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usedHint => $composableBuilder(
    column: $table.usedHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewAttemptsTable> {
  $$ReviewAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usedHint => $composableBuilder(
    column: $table.usedHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewAttemptsTable> {
  $$ReviewAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<bool> get usedHint =>
      $composableBuilder(column: $table.usedHint, builder: (column) => column);

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReviewAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewAttemptsTable,
          ReviewAttempt,
          $$ReviewAttemptsTableFilterComposer,
          $$ReviewAttemptsTableOrderingComposer,
          $$ReviewAttemptsTableAnnotationComposer,
          $$ReviewAttemptsTableCreateCompanionBuilder,
          $$ReviewAttemptsTableUpdateCompanionBuilder,
          (
            ReviewAttempt,
            BaseReferences<_$AppDatabase, $ReviewAttemptsTable, ReviewAttempt>,
          ),
          ReviewAttempt,
          PrefetchHooks Function()
        > {
  $$ReviewAttemptsTableTableManager(
    _$AppDatabase db,
    $ReviewAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attemptId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> dimension = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<bool> usedHint = const Value.absent(),
                Value<int> latencyMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewAttemptsCompanion(
                attemptId: attemptId,
                itemId: itemId,
                dimension: dimension,
                result: result,
                correct: correct,
                usedHint: usedHint,
                latencyMs: latencyMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attemptId,
                required String itemId,
                required String dimension,
                required String result,
                required bool correct,
                required bool usedHint,
                required int latencyMs,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReviewAttemptsCompanion.insert(
                attemptId: attemptId,
                itemId: itemId,
                dimension: dimension,
                result: result,
                correct: correct,
                usedHint: usedHint,
                latencyMs: latencyMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewAttemptsTable,
      ReviewAttempt,
      $$ReviewAttemptsTableFilterComposer,
      $$ReviewAttemptsTableOrderingComposer,
      $$ReviewAttemptsTableAnnotationComposer,
      $$ReviewAttemptsTableCreateCompanionBuilder,
      $$ReviewAttemptsTableUpdateCompanionBuilder,
      (
        ReviewAttempt,
        BaseReferences<_$AppDatabase, $ReviewAttemptsTable, ReviewAttempt>,
      ),
      ReviewAttempt,
      PrefetchHooks Function()
    >;
typedef $$SpeakingAttemptsTableCreateCompanionBuilder =
    SpeakingAttemptsCompanion Function({
      required String attemptId,
      required String targetId,
      Value<double?> localScore,
      Value<double?> providerScore,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SpeakingAttemptsTableUpdateCompanionBuilder =
    SpeakingAttemptsCompanion Function({
      Value<String> attemptId,
      Value<String> targetId,
      Value<double?> localScore,
      Value<double?> providerScore,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SpeakingAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeakingAttemptsTable> {
  $$SpeakingAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get localScore => $composableBuilder(
    column: $table.localScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get providerScore => $composableBuilder(
    column: $table.providerScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeakingAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeakingAttemptsTable> {
  $$SpeakingAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get localScore => $composableBuilder(
    column: $table.localScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get providerScore => $composableBuilder(
    column: $table.providerScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeakingAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeakingAttemptsTable> {
  $$SpeakingAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<double> get localScore => $composableBuilder(
    column: $table.localScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get providerScore => $composableBuilder(
    column: $table.providerScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SpeakingAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeakingAttemptsTable,
          SpeakingAttempt,
          $$SpeakingAttemptsTableFilterComposer,
          $$SpeakingAttemptsTableOrderingComposer,
          $$SpeakingAttemptsTableAnnotationComposer,
          $$SpeakingAttemptsTableCreateCompanionBuilder,
          $$SpeakingAttemptsTableUpdateCompanionBuilder,
          (
            SpeakingAttempt,
            BaseReferences<
              _$AppDatabase,
              $SpeakingAttemptsTable,
              SpeakingAttempt
            >,
          ),
          SpeakingAttempt,
          PrefetchHooks Function()
        > {
  $$SpeakingAttemptsTableTableManager(
    _$AppDatabase db,
    $SpeakingAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeakingAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeakingAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeakingAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attemptId = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<double?> localScore = const Value.absent(),
                Value<double?> providerScore = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeakingAttemptsCompanion(
                attemptId: attemptId,
                targetId: targetId,
                localScore: localScore,
                providerScore: providerScore,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attemptId,
                required String targetId,
                Value<double?> localScore = const Value.absent(),
                Value<double?> providerScore = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SpeakingAttemptsCompanion.insert(
                attemptId: attemptId,
                targetId: targetId,
                localScore: localScore,
                providerScore: providerScore,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeakingAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeakingAttemptsTable,
      SpeakingAttempt,
      $$SpeakingAttemptsTableFilterComposer,
      $$SpeakingAttemptsTableOrderingComposer,
      $$SpeakingAttemptsTableAnnotationComposer,
      $$SpeakingAttemptsTableCreateCompanionBuilder,
      $$SpeakingAttemptsTableUpdateCompanionBuilder,
      (
        SpeakingAttempt,
        BaseReferences<_$AppDatabase, $SpeakingAttemptsTable, SpeakingAttempt>,
      ),
      SpeakingAttempt,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxEventsTableCreateCompanionBuilder =
    SyncOutboxEventsCompanion Function({
      required String eventId,
      required String entityType,
      required String payloadJson,
      required DateTime occurredAt,
      Value<int> attempts,
      Value<DateTime?> acknowledgedAt,
      Value<int> rowid,
    });
typedef $$SyncOutboxEventsTableUpdateCompanionBuilder =
    SyncOutboxEventsCompanion Function({
      Value<String> eventId,
      Value<String> entityType,
      Value<String> payloadJson,
      Value<DateTime> occurredAt,
      Value<int> attempts,
      Value<DateTime?> acknowledgedAt,
      Value<int> rowid,
    });

class $$SyncOutboxEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxEventsTable> {
  $$SyncOutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxEventsTable> {
  $$SyncOutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxEventsTable> {
  $$SyncOutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );
}

class $$SyncOutboxEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxEventsTable,
          SyncOutboxEvent,
          $$SyncOutboxEventsTableFilterComposer,
          $$SyncOutboxEventsTableOrderingComposer,
          $$SyncOutboxEventsTableAnnotationComposer,
          $$SyncOutboxEventsTableCreateCompanionBuilder,
          $$SyncOutboxEventsTableUpdateCompanionBuilder,
          (
            SyncOutboxEvent,
            BaseReferences<
              _$AppDatabase,
              $SyncOutboxEventsTable,
              SyncOutboxEvent
            >,
          ),
          SyncOutboxEvent,
          PrefetchHooks Function()
        > {
  $$SyncOutboxEventsTableTableManager(
    _$AppDatabase db,
    $SyncOutboxEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEventsCompanion(
                eventId: eventId,
                entityType: entityType,
                payloadJson: payloadJson,
                occurredAt: occurredAt,
                attempts: attempts,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String entityType,
                required String payloadJson,
                required DateTime occurredAt,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEventsCompanion.insert(
                eventId: eventId,
                entityType: entityType,
                payloadJson: payloadJson,
                occurredAt: occurredAt,
                attempts: attempts,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxEventsTable,
      SyncOutboxEvent,
      $$SyncOutboxEventsTableFilterComposer,
      $$SyncOutboxEventsTableOrderingComposer,
      $$SyncOutboxEventsTableAnnotationComposer,
      $$SyncOutboxEventsTableCreateCompanionBuilder,
      $$SyncOutboxEventsTableUpdateCompanionBuilder,
      (
        SyncOutboxEvent,
        BaseReferences<_$AppDatabase, $SyncOutboxEventsTable, SyncOutboxEvent>,
      ),
      SyncOutboxEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstalledContentPackagesTableTableManager get installedContentPackages =>
      $$InstalledContentPackagesTableTableManager(
        _db,
        _db.installedContentPackages,
      );
  $$LessonProgressEntriesTableTableManager get lessonProgressEntries =>
      $$LessonProgressEntriesTableTableManager(_db, _db.lessonProgressEntries);
  $$MasteryStatesTableTableManager get masteryStates =>
      $$MasteryStatesTableTableManager(_db, _db.masteryStates);
  $$ReviewAttemptsTableTableManager get reviewAttempts =>
      $$ReviewAttemptsTableTableManager(_db, _db.reviewAttempts);
  $$SpeakingAttemptsTableTableManager get speakingAttempts =>
      $$SpeakingAttemptsTableTableManager(_db, _db.speakingAttempts);
  $$SyncOutboxEventsTableTableManager get syncOutboxEvents =>
      $$SyncOutboxEventsTableTableManager(_db, _db.syncOutboxEvents);
}
