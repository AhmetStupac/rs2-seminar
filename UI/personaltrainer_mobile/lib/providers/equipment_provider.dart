import 'package:personaltrainer_mobile/models/equipment.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class EquipmentProvider extends BaseProvider<Equipment> {
  EquipmentProvider() : super("Equipment");

  //1. korak importovati model.
  //2. dodati u main.dart, provider -> void metoda ChangeNotifierProvider<EquipmentProvider>(
  //   create: (_) => EquipmentProvider(),
  //),
  //3. ako nesto radim sa providerom, obavezno uraditi hot restart

  @override
  Equipment fromJson(data) {
    return Equipment.fromJson(data);
  }
}
