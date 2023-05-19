import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/email_template_model.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_results_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class EmailTemplateRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();
  Future<EmailTemplateModel> sendEmailTemplateFuture(
      String? projectID,
      String? quoteID,
      String? email,
      String? category,
      String? total,
      String? userName) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    // '/authenticate?username=$userCode&userType=$userType',
    String? token = await secureStorageProvider.read(key: 'token');

   var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=send-mail&QUOTOKEN=${Journey.token}',
      body: {
        "amount": total,
        "PROJECTID": projectID,
        "QUOTEID": quoteID,
        "fullname": userName,
        "emailid": email,
        "category": category
       
      },
    );
    if ((response != null) || response!['data'] != null) {
      return EmailTemplateModel.fromJson(response);
    }
    throw BadRequestException(message: 'Authenticate Token Not Fount');
  }
}
