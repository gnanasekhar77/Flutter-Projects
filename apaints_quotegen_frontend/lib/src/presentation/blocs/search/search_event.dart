// abstract class SearchEvent {}

// class GetSearchListEvent extends SearchEvent {
//   final String? searchItem;

//   GetSearchListEvent({
//     this.searchItem,
//   });

//   @override
//   List<Object> get props => [];
// }
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {}

class Search extends SearchEvent {
  String query;

  Search({required this.query});

  @override
  List<Object> get props => [];
}
