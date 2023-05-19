import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';

import '../../core/utils/get_it.dart';

class Repository {
  final apiProvider = getSingleton<APIProvider>();
}
