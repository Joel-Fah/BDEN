import 'package:get/get.dart';
import '../../../data/models/myth_model.dart';
import '../../../data/repositories/myth_repository.dart';
import '../../../core/enums/myth_category.dart';

class MythController extends GetxController {
  final MythRepository _mythService;
  MythController(this._mythService);

  final myths = <MythModel>[].obs;
  final selectedCategory = Rxn<MythCategory>();
  final isLoading = true.obs;
  final expandedMythId = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadMyths();
  }

  Future<void> loadMyths() async {
    isLoading.value = true;
    myths.value = selectedCategory.value == null
        ? await _mythService.getMyths()
        : await _mythService.getMythsByCategory(selectedCategory.value!);
    isLoading.value = false;
  }

  void setCategory(MythCategory? cat) {
    selectedCategory.value = cat;
    loadMyths();
  }

  void toggleMyth(String id) {
    expandedMythId.value = expandedMythId.value == id ? null : id;
  }
}
