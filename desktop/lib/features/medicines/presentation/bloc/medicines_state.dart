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

  const MedicinesLoadedState({
    required this.medicines,
    required this.filteredMedicines,
    this.searchQuery = '',
  });

  MedicinesLoadedState copyWith({
    List<Medicine>? medicines,
    List<Medicine>? filteredMedicines,
    String? searchQuery,
  }) {
    return MedicinesLoadedState(
      medicines: medicines ?? this.medicines,
      filteredMedicines: filteredMedicines ?? this.filteredMedicines,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class MedicinesErrorState extends MedicinesState {
  final String message;
  const MedicinesErrorState(this.message);
}
