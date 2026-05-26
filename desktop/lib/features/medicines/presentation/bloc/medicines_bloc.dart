import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/medicines/domain/entities/medicine.dart';
import 'package:desktop/features/medicines/domain/usecases/create_medicine.dart';
import 'package:desktop/features/medicines/domain/usecases/delete_medicine.dart';
import 'package:desktop/features/medicines/domain/usecases/get_medicines.dart';
import 'package:desktop/features/medicines/domain/usecases/update_medicine.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_event.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_state.dart';

class MedicinesBloc extends Bloc<MedicinesEvent, MedicinesState> {
  final GetMedicines getMedicinesUseCase;
  final CreateMedicine createMedicineUseCase;
  final UpdateMedicine updateMedicineUseCase;
  final DeleteMedicine deleteMedicineUseCase;

  MedicinesBloc({
    required this.getMedicinesUseCase,
    required this.createMedicineUseCase,
    required this.updateMedicineUseCase,
    required this.deleteMedicineUseCase,
  }) : super(const MedicinesInitialState()) {
    on<LoadMedicinesEvent>(_onLoadMedicines);
    on<AddMedicineEvent>(_onAddMedicine);
    on<EditMedicineEvent>(_onEditMedicine);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<SearchMedicinesEvent>(_onSearchMedicines);
  }

  Future<void> _onLoadMedicines(LoadMedicinesEvent event, Emitter<MedicinesState> emit) async {
    emit(const MedicinesLoadingState());
    final result = await getMedicinesUseCase();
    result.fold(
      (failure) => emit(MedicinesErrorState(failure.message)),
      (medicines) => emit(MedicinesLoadedState(
        medicines: medicines,
        filteredMedicines: medicines,
      )),
    );
  }

  Future<void> _onAddMedicine(AddMedicineEvent event, Emitter<MedicinesState> emit) async {
    final result = await createMedicineUseCase(event.medicine);
    result.fold(
      (failure) => emit(MedicinesErrorState(failure.message)),
      (newMedicine) {
        if (state is MedicinesLoadedState) {
          final currentState = state as MedicinesLoadedState;
          final updatedList = List<Medicine>.from(currentState.medicines)..add(newMedicine);
          emit(currentState.copyWith(
            medicines: updatedList,
            filteredMedicines: _applySearch(updatedList, currentState.searchQuery),
          ));
        } else {
          add(const LoadMedicinesEvent());
        }
      },
    );
  }

  Future<void> _onEditMedicine(EditMedicineEvent event, Emitter<MedicinesState> emit) async {
    final result = await updateMedicineUseCase(event.medicine);
    result.fold(
      (failure) => emit(MedicinesErrorState(failure.message)),
      (updatedMedicine) {
        if (state is MedicinesLoadedState) {
          final currentState = state as MedicinesLoadedState;
          final updatedList = currentState.medicines.map((m) {
            return m.id == updatedMedicine.id ? updatedMedicine : m;
          }).toList();
          emit(currentState.copyWith(
            medicines: updatedList,
            filteredMedicines: _applySearch(updatedList, currentState.searchQuery),
          ));
        } else {
          add(const LoadMedicinesEvent());
        }
      },
    );
  }

  Future<void> _onDeleteMedicine(DeleteMedicineEvent event, Emitter<MedicinesState> emit) async {
    final result = await deleteMedicineUseCase(event.id);
    result.fold(
      (failure) => emit(MedicinesErrorState(failure.message)),
      (_) {
        if (state is MedicinesLoadedState) {
          final currentState = state as MedicinesLoadedState;
          final updatedList = currentState.medicines.where((m) => m.id != event.id).toList();
          emit(currentState.copyWith(
            medicines: updatedList,
            filteredMedicines: _applySearch(updatedList, currentState.searchQuery),
          ));
        } else {
          add(const LoadMedicinesEvent());
        }
      },
    );
  }

  void _onSearchMedicines(SearchMedicinesEvent event, Emitter<MedicinesState> emit) {
    if (state is MedicinesLoadedState) {
      final currentState = state as MedicinesLoadedState;
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredMedicines: _applySearch(currentState.medicines, event.query),
      ));
    }
  }

  List<Medicine> _applySearch(List<Medicine> list, String query) {
    if (query.trim().isEmpty) return list;
    final lowerQuery = query.toLowerCase();
    return list.where((m) {
      final nameMatch = m.name.toLowerCase().contains(lowerQuery);
      final categoryMatch = m.category.toLowerCase().contains(lowerQuery);
      final barcodeMatch = m.barcode?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatch || categoryMatch || barcodeMatch;
    }).toList();
  }
}
