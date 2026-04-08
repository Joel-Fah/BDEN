import '../models/myth_model.dart';
import '../../core/enums/myth_category.dart';

abstract class MythRepository {
  Future<List<MythModel>> getMyths();
  Future<List<MythModel>> getMythsByCategory(MythCategory category);
}
