part of 'categories_bloc.dart';

class CategoriesState extends Equatable {
  final Status status;
  final List<Category> categories;
  final String message;

  const CategoriesState({
    this.status = Status.initial,
    this.categories = const [],
    this.message = '',
  });

  CategoriesState copyWith({
    Status? status,
    List<Category>? categories,
    String? message,
  }) => CategoriesState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    message: message ?? this.message,
  );

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'categories': categories.map((c) => c.toJson()).toList(),
  };

  factory CategoriesState.fromMap(Map<String, dynamic> map) => CategoriesState(
    status: Status.values.byName(map['status'] as String),
    categories: listFromJson(map['categories'], Category.fromJson),
  );

  @override
  List<Object?> get props => [status, categories, message];
}
