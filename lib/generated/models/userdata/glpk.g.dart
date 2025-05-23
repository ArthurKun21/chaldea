// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/glpk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeLPParams _$FreeLPParamsFromJson(Map json) => $checkedCreate('FreeLPParams', json, ($checkedConvert) {
  final val = FreeLPParams(
    rows: $checkedConvert('rows', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    progress: $checkedConvert('progress', (v) => (v as num?)?.toInt() ?? -1),
    blacklist: $checkedConvert('blacklist', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
    minCost: $checkedConvert('minCost', (v) => (v as num?)?.toInt() ?? 0),
    costMinimize: $checkedConvert('costMinimize', (v) => v as bool? ?? true),
    extraCols: $checkedConvert('extraCols', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    integerResult: $checkedConvert('integerResult', (v) => v as bool? ?? false),
    useAP20: $checkedConvert('useAP20', (v) => v as bool? ?? true),
    apHalfDailyQuest: $checkedConvert(
      'apHalfDailyQuest',
      (v) => $enumDecodeNullable(_$QuestApReduceTypeEnumMap, v) ?? QuestApReduceType.none,
    ),
    apHalfOrdealCall: $checkedConvert('apHalfOrdealCall', (v) => v as bool? ?? false),
    bondBonusPercent: $checkedConvert('bondBonusPercent', (v) => (v as num?)?.toInt() ?? 0),
    bondBonusCount: $checkedConvert('bondBonusCount', (v) => (v as num?)?.toInt() ?? 0),
    planItemCounts: $checkedConvert(
      'planItemCounts',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    planItemWeights: $checkedConvert(
      'planItemWeights',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toDouble())),
    ),
    planItemBonus: $checkedConvert(
      'planItemBonus',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
  );
  return val;
});

Map<String, dynamic> _$FreeLPParamsToJson(FreeLPParams instance) => <String, dynamic>{
  'rows': instance.rows,
  'planItemCounts': instance.planItemCounts.map((k, e) => MapEntry(k.toString(), e)),
  'planItemWeights': instance.planItemWeights.map((k, e) => MapEntry(k.toString(), e)),
  'planItemBonus': instance.planItemBonus.map((k, e) => MapEntry(k.toString(), e)),
  'progress': instance.progress,
  'blacklist': instance.blacklist.toList(),
  'minCost': instance.minCost,
  'costMinimize': instance.costMinimize,
  'extraCols': instance.extraCols,
  'integerResult': instance.integerResult,
  'useAP20': instance.useAP20,
  'apHalfDailyQuest': _$QuestApReduceTypeEnumMap[instance.apHalfDailyQuest]!,
  'apHalfOrdealCall': instance.apHalfOrdealCall,
  'bondBonusPercent': instance.bondBonusPercent,
  'bondBonusCount': instance.bondBonusCount,
};

const _$QuestApReduceTypeEnumMap = {
  QuestApReduceType.none: 'none',
  QuestApReduceType.half: 'half',
  QuestApReduceType.third: 'third',
};

LPSolution _$LPSolutionFromJson(Map json) => $checkedCreate('LPSolution', json, ($checkedConvert) {
  final val = LPSolution(
    destination: $checkedConvert('destination', (v) => (v as num?)?.toInt() ?? 0),
    originalItems: $checkedConvert(
      'originalItems',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    totalCost: $checkedConvert('totalCost', (v) => (v as num?)?.toInt()),
    totalNum: $checkedConvert('totalNum', (v) => (v as num?)?.toInt()),
    countVars: $checkedConvert(
      'countVars',
      (v) =>
          (v as List<dynamic>?)?.map((e) => LPVariable<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
    weightVars: $checkedConvert(
      'weightVars',
      (v) =>
          (v as List<dynamic>?)?.map((e) => LPVariable<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$LPSolutionToJson(LPSolution instance) => <String, dynamic>{
  'destination': instance.destination,
  'originalItems': instance.originalItems,
  'totalCost': instance.totalCost,
  'totalNum': instance.totalNum,
  'countVars': instance.countVars.map((e) => e.toJson()).toList(),
  'weightVars': instance.weightVars.map((e) => e.toJson()).toList(),
};

LPVariable<T> _$LPVariableFromJson<T>(Map json, T Function(Object? json) fromJsonT) =>
    $checkedCreate('LPVariable', json, ($checkedConvert) {
      final val = LPVariable<T>(
        name: $checkedConvert('name', (v) => (v as num).toInt()),
        displayName: $checkedConvert('displayName', (v) => v as String?),
        value: $checkedConvert('value', (v) => fromJsonT(v)),
        cost: $checkedConvert('cost', (v) => (v as num).toInt()),
        detail: $checkedConvert(
          'detail',
          (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toDouble())),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LPVariableToJson<T>(LPVariable<T> instance, Object? Function(T value) toJsonT) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'value': toJsonT(instance.value),
      'cost': instance.cost,
      'detail': instance.detail.map((k, e) => MapEntry(k.toString(), e)),
    };

BasicLPParams _$BasicLPParamsFromJson(Map json) => $checkedCreate('BasicLPParams', json, ($checkedConvert) {
  final val = BasicLPParams(
    colNames: $checkedConvert('colNames', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    rowNames: $checkedConvert('rowNames', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    matA: $checkedConvert(
      'matA',
      (v) => (v as List<dynamic>?)?.map((e) => (e as List<dynamic>).map((e) => e as num).toList()).toList(),
    ),
    bVec: $checkedConvert('bVec', (v) => (v as List<dynamic>?)?.map((e) => e as num).toList()),
    cVec: $checkedConvert('cVec', (v) => (v as List<dynamic>?)?.map((e) => e as num).toList()),
    integer: $checkedConvert('integer', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$BasicLPParamsToJson(BasicLPParams instance) => <String, dynamic>{
  'colNames': instance.colNames,
  'rowNames': instance.rowNames,
  'matA': instance.matA,
  'bVec': instance.bVec,
  'cVec': instance.cVec,
  'integer': instance.integer,
};
