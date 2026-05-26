import 'package:desktop/features/medicines/domain/entities/medicine.dart';

abstract class MedicinesState {
  const MedicinesState();
}

class MedicinesInitialState extends MedicinesState {
  const MedicinesInitialState();
}

class MedicinesLoadingState extends MedicinesState {
  const MedicinesLoadingState();
}

class MedicinesLoadedState extends MedicinesState {
  final List<Medicine> medicines;
  final List<Medicine> filteredMedicines;
  final String searchQuery;
  final String? selectedCategory;
  final bool? selectedStatus;

  const MedicinesLoadedState({
    required this.medicines,
    required this.filteredMedicines,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedStatus,
  });

  MedicinesLoadedState copyWith({
    List<Medicine>? medicines,
    List<Medicine>? filteredMedicines,
    String? searchQuery,
    String? Function()? selectedCategory,
    bool? Function()? selectedStatus,
  }) {
    return MedicinesLoadedState(
      medicines: medicines ?? this.medicines,
      filteredMedicines: filteredMedicines ?? this.filteredMedicines,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      selectedStatus: selectedStatus != null ? selectedStatus() : this.selectedStatus,
    );
  }
}

class MedicinesErrorState extends MedicinesState {
  final String message;
  const MedicinesErrorState(this.message);
}
