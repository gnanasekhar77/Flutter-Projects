import 'package:APaints_QGen/src/data/datasources/remote/alice_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_info_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/connectivity_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/easy_localization_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/repositories/authentication_repo.dart';
import 'package:APaints_QGen/src/data/repositories/categories_repo.dart';
import 'package:APaints_QGen/src/data/repositories/clone_project_repo.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_list_repo.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_result_repo.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_san_bund_repo.dart';
import 'package:APaints_QGen/src/data/repositories/copy_quote_repo.dart';
import 'package:APaints_QGen/src/data/repositories/create_project_repo.dart';
import 'package:APaints_QGen/src/data/repositories/create_quote_to_project_repo.dart';
import 'package:APaints_QGen/src/data/repositories/delete_quote_repo.dart';
import 'package:APaints_QGen/src/data/repositories/delete_sku_repo.dart';
import 'package:APaints_QGen/src/data/repositories/email_template_repo.dart';
import 'package:APaints_QGen/src/data/repositories/export_project_repo.dart';
import 'package:APaints_QGen/src/data/repositories/flip_quote_repo.dart';
import 'package:APaints_QGen/src/data/repositories/fr_authentication_repo.dart';
import 'package:APaints_QGen/src/data/repositories/get_token_repo.dart';
import 'package:APaints_QGen/src/data/repositories/login_repo_impl.dart';
import 'package:APaints_QGen/src/data/repositories/project_description_repo.dart';
import 'package:APaints_QGen/src/data/repositories/projects_repo.dart';
import 'package:APaints_QGen/src/data/repositories/search_repo.dart';
import 'package:APaints_QGen/src/data/repositories/sku_repo.dart';
import 'package:APaints_QGen/src/data/repositories/temp_quote_search_result_repo.dart';
import 'package:APaints_QGen/src/data/repositories/template_quote_list_repo.dart';
import 'package:APaints_QGen/src/data/repositories/token_repo.dart';
import 'package:APaints_QGen/src/data/repositories/validate_otp_repo.dart';
import 'package:APaints_QGen/src/data/repositories/view_quote_repo.dart';
import 'package:get_it/get_it.dart';

final _serviceLocator = GetIt.instance;

Future<void> _setupRepositories() async {
  _serviceLocator.registerLazySingleton(() => AuthenticationRepository());
  _serviceLocator.registerLazySingleton(() => FRAuthenticationRepo());
  _serviceLocator.registerLazySingleton(() => GetTokenRepository());
  _serviceLocator.registerLazySingleton(() => LoginRepositoryImpl());
  _serviceLocator.registerLazySingleton(() => ValidateOTPRepo());
  _serviceLocator.registerLazySingleton(() => GetCategoriesRepository());
  _serviceLocator.registerLazySingleton(() => GetSkuRepository());
  _serviceLocator.registerLazySingleton(() => ViewQuoteRepository());
  _serviceLocator.registerLazySingleton(() => GetProjectsRepository());
  _serviceLocator.registerLazySingleton(() => CreateQuoteToProjectRepository());
  _serviceLocator.registerLazySingleton(() => ProjectDescriptionRepository());
  _serviceLocator.registerLazySingleton(() => CloneProjectRepository());
  _serviceLocator.registerLazySingleton(() => FlipQuoteRepository());
  _serviceLocator.registerLazySingleton(() => ExportProjectRepository());
  _serviceLocator.registerLazySingleton(() => DeleteQuoteRepository());
  _serviceLocator.registerLazySingleton(() => CreateProjectRepository());
  _serviceLocator.registerLazySingleton(() => SearchRepositoryImpl());
  _serviceLocator
      .registerLazySingleton(() => CompetitionSearchListRepository());
  _serviceLocator
      .registerLazySingleton(() => CompetitionSearchResultRepository());
  _serviceLocator.registerLazySingleton(() => TemplateQuoteListRepository());
  _serviceLocator
      .registerLazySingleton(() => TempQuoteSearchResultRepository());
  _serviceLocator.registerLazySingleton(() => CopyQuoteRepository());
  _serviceLocator.registerLazySingleton(() => DeleteSkuRepository());
  _serviceLocator
      .registerLazySingleton(() => CompetitionSearchSanBundRepository());
  _serviceLocator.registerLazySingleton(() => EmailTemplateRepository());
  _serviceLocator.registerLazySingleton(() => TokenRepository());
}

Future<void> _setupProviders() async {
  _serviceLocator
      .registerSingleton<SecureStorageProvider>(SecureStorageProvider());
  _serviceLocator.registerSingleton<AppInfoProvider>(AppInfoProvider());
  _serviceLocator
      .registerSingleton<FlutterToastProvider>(FlutterToastProvider());
  _serviceLocator.registerSingleton<AppConfigProvider>(AppConfigProvider());
  _serviceLocator
      .registerSingleton<ConnectivityProvider>(ConnectivityProvider());
  _serviceLocator.registerSingleton<APIProvider>(APIProvider());
  _serviceLocator.registerSingleton<AliceProvider>(AliceProvider());

  _serviceLocator
      .registerSingleton<EasyLocalizationProvider>(EasyLocalizationProvider());
  _serviceLocator.registerSingleton<FormFieldValidatorProvider>(
      FormFieldValidatorProvider());
}

Future<void> _setupConfig() async {
  await _serviceLocator.get<AppInfoProvider>().setupAppInfo();
  // await _serviceLocator.get<AppConfigProvider>().loadConfig();
  await _serviceLocator.get<ConnectivityProvider>().initialize();
  await _serviceLocator.get<EasyLocalizationProvider>().ensureInitialized();
}

Future<void> setupResources() async {
  await _setupProviders();
  await _setupConfig();
  await _setupRepositories();
}
