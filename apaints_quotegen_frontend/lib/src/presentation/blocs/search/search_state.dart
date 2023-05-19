import 'package:APaints_QGen/src/data/models/search_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';

// abstract class SearchState {}

// class SearchInitial extends SearchState {}

// class SearchLoading extends SearchState {}

// class SearchFailure extends SearchState {
//   final String message;

//   SearchFailure({required this.message});
// }

// class SearchLoaded extends SearchState {
//   List<Data> searchResponseModel;
//   SearchLoaded({required this.searchResponseModel});

//   @override
//   List<Object> get props => [];
// }

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class SearchState extends Equatable {}

class SearchUninitialized extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchLoading extends SearchState {
  SearchLoading();
  @override
  List<Object> get props => [];
}

class SearchLoaded extends SearchState {
  List<SKUData> searchResponseModel;
  SearchLoaded({required this.searchResponseModel});
  @override
  List<Object> get props => [];
}

class SearchError extends SearchState {
  @override
  List<Object> get props => [];
}
