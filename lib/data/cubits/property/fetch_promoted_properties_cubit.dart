// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../Repositories/property_repository.dart';
import '../../model/data_output.dart';
import '../../model/property_model.dart';

abstract class FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInitial extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInProgress extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesSuccess extends FetchPromotedPropertiesState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<PropertyModel> propertymodel;
  final int offset;
  final int total;
  FetchPromotedPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.propertymodel,
    required this.offset,
    required this.total,
  });

  FetchPromotedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchPromotedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      propertymodel: propertymodel ?? this.propertymodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isLoadingMore': isLoadingMore,
      'loadingMoreError': loadingMoreError,
      'propertymodel': propertymodel.map((x) => x.toMap()).toList(),
      'offset': offset,
      'total': total,
    };
  }

  factory FetchPromotedPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchPromotedPropertiesSuccess(
      isLoadingMore: map['isLoadingMore'] as bool,
      loadingMoreError: map['loadingMoreError'] as bool,
      propertymodel: List<PropertyModel>.from(
        (map['propertymodel'] as List).map<PropertyModel>(
          (x) => PropertyModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      offset: map['offset'] as int,
      total: map['total'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchPromotedPropertiesSuccess.fromJson(String source) =>
      FetchPromotedPropertiesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

class FetchPromotedPropertiesFailure extends FetchPromotedPropertiesState {
  final String errorMessage;
  FetchPromotedPropertiesFailure(this.errorMessage);
}

class FetchPromotedPropertiesCubit extends Cubit<FetchPromotedPropertiesState>
    with HydratedMixin {
  FetchPromotedPropertiesCubit() : super(FetchPromotedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> fetchPromotedProperties({bool? forceRefresh}) async {
    if (forceRefresh != true) {
      if (state is FetchPromotedPropertiesSuccess) {
        await Future.delayed(const Duration(seconds: 5));
        log("##waited promoted");
      } else {
        emit(FetchPromotedPropertiesInProgress());
      }
    } else {
      emit(FetchPromotedPropertiesInProgress());
    }

    try {
      // emit(FetchPromotedPropertiesInProgress());
      log("##called promoted");

      DataOutput<PropertyModel> result =
          await _propertyRepository.fetchPromotedProperty(
        offset: 0,
        sendCityName: true,
      );

      emit(FetchPromotedPropertiesSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          propertymodel: result.modelList,
          offset: 0,
          total: result.total));
    } catch (e) {
      emit(FetchPromotedPropertiesFailure(e.toString()));
    }
  }

  update(PropertyModel model) {
    if (state is FetchPromotedPropertiesSuccess) {
      List<PropertyModel> properties =
          (state as FetchPromotedPropertiesSuccess).propertymodel;

      var index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit((state as FetchPromotedPropertiesSuccess)
          .copyWith(propertymodel: properties));
    }
  }

  Future<void> fetchPromotedPropertiesMore() async {
    try {
      if (state is FetchPromotedPropertiesSuccess) {
        if ((state as FetchPromotedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchPromotedPropertiesSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchPromotedProperty(
                offset: (state as FetchPromotedPropertiesSuccess)
                    .propertymodel
                    .length,
                sendCityName: true);

        FetchPromotedPropertiesSuccess propertymodelState =
            (state as FetchPromotedPropertiesSuccess);
        propertymodelState.propertymodel.addAll(result.modelList);
        emit(FetchPromotedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            propertymodel: propertymodelState.propertymodel,
            offset:
                (state as FetchPromotedPropertiesSuccess).propertymodel.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchPromotedPropertiesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchPromotedPropertiesSuccess) {
      return (state as FetchPromotedPropertiesSuccess).propertymodel.length <
          (state as FetchPromotedPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchPromotedPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      FetchPromotedPropertiesSuccess fetchPromotedPropertiesSuccess =
          FetchPromotedPropertiesSuccess.fromMap(json);
      log(fetchPromotedPropertiesSuccess.toJson(), name: "@@EE");
      return fetchPromotedPropertiesSuccess;
    } catch (e, st) {
      log("#%%%# E $e $st");
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchPromotedPropertiesState state) {
    log("cubitusing");
    if (state is FetchPromotedPropertiesSuccess) {
      Map<String, dynamic> mapped = state.toMap();

      mapped['cubit_state'] = "FetchPromotedPropertiesState";

      return mapped;
    }

    return null;
  }
}
