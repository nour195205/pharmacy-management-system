import 'package:desktop/features/medicines/domain/entities/medicine.dart';

abstract class MedicinesEvent {
  const MedicinesEvent();
}

class LoadMedicinesEvent extends MedicinesEvent {
  const LoadMedicinesEvent();
}

class AddMedicineEvent extends MedicinesEvent {
  final Medicine medicine;
  const AddMedicineEvent(this.medicine);
}

class EditMedicineEvent extends MedicinesEvent {
  final Medicine medicine;
  const EditMedicineEvent(this.medicine);
}

class DeleteMedicineEvent extends MedicinesEvent {
  final String id;
  const DeleteMedicineEvent(this.id);
}

class SearchMedicinesEvent extends MedicinesEvent {
  final String query;
  const SearchMedicinesEvent(this.query);
}
