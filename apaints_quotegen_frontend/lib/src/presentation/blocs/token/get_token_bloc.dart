import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/token_model/get_token_model.dart';
import 'package:APaints_QGen/src/data/models/tokens_model.dart';
import 'package:APaints_QGen/src/data/repositories/get_token_repo.dart';
import 'package:APaints_QGen/src/data/repositories/token_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/token/get_token_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/token/get_token_state.dart';
import 'package:bloc/bloc.dart';

class TokenBloc extends Bloc<GetTokenEvent, TokenState> {
  final _apiProvider = getSingleton<APIProvider>();
  final categoriesRepo = getSingleton<TokenRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  TokensModel? getCategoriesModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getTokens(String token) async {
    add(
      GetTokenEvent(token: token),
    );
  }

  TokenBloc() : super(TokenInitial()) {
    on<GetTokenEvent>((event, emit) => getToken(event, emit));
  }

  void getToken(GetTokenEvent event, Emitter<TokenState> emit) async {
    emit(TokenLoading());
    try {
      TokensModel response = await categoriesRepo.getTokenFuture(event.token);
      getCategoriesModel = response;
      logger("Response in AuthBloc: $response");
      if (getCategoriesModel!.statusCode!.toString() == '200') {
        logger("TOKEN: ${getCategoriesModel?.statusCode ?? ''}");

        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(TokenLoaded());
      } else {
        emit(TokenFailure(message: getCategoriesModel!.statusCode!.toString()));
      }
    } catch (e, st) {
      logES(e, st);

      emit(TokenFailure(message: e.toString()));
    }
  }
}
