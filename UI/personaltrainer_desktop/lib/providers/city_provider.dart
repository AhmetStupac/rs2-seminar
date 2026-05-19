import 'package:personaltrainer_desktop/models/city.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(data) {
    return City.fromJson(data);
  }
}
