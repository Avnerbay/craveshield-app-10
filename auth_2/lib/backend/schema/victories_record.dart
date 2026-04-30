import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VictoriesRecord extends FirestoreRecord {
  VictoriesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "victoryCount" field.
  int? _victoryCount;
  int get victoryCount => _victoryCount ?? 0;
  bool hasVictoryCount() => _victoryCount != null;

  void _initializeFields() {
    _victoryCount = castToType<int>(snapshotData['victoryCount']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('victories');

  static Stream<VictoriesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VictoriesRecord.fromSnapshot(s));

  static Future<VictoriesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VictoriesRecord.fromSnapshot(s));

  static VictoriesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VictoriesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VictoriesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VictoriesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VictoriesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VictoriesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVictoriesRecordData({
  int? victoryCount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'victoryCount': victoryCount,
    }.withoutNulls,
  );

  return firestoreData;
}

class VictoriesRecordDocumentEquality implements Equality<VictoriesRecord> {
  const VictoriesRecordDocumentEquality();

  @override
  bool equals(VictoriesRecord? e1, VictoriesRecord? e2) {
    return e1?.victoryCount == e2?.victoryCount;
  }

  @override
  int hash(VictoriesRecord? e) => const ListEquality().hash([e?.victoryCount]);

  @override
  bool isValidKey(Object? o) => o is VictoriesRecord;
}
