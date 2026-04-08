import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/myth_model.dart';
import '../repositories/myth_repository.dart';
import '../../core/enums/myth_category.dart';

class MythService extends GetxService implements MythRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _col => _firestore.collection('myths');

  @override
  Future<List<MythModel>> getMyths() async {
    final snap = await _col.orderBy('order').get();
    return snap.docs
        .map((d) => MythModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MythModel>> getMythsByCategory(MythCategory category) async {
    final snap = await _col
        .where('category', isEqualTo: category.name)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => MythModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }
}
