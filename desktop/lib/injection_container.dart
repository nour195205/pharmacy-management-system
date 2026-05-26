import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/medicines/data/datasources/medicines_local_data_source.dart';
import 'package:desktop/features/medicines/data/datasources/medicines_remote_data_source.dart';
import 'package:desktop/features/medicines/data/repositories/medicines_repository_impl.dart';
import 'package:desktop/features/medicines/domain/repositories/medicines_repository.dart';
import 'package:desktop/features/medicines/domain/usecases/create_medicine.dart';
import 'package:desktop/features/medicines/domain/usecases/delete_medicine.dart';
import 'package:desktop/features/medicines/domain/usecases/get_medicines.dart';
import 'package:desktop/features/medicines/domain/usecases/update_medicine.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_bloc.dart';
import 'package:desktop/services/api_service.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Medicines
  // BLoC
  sl.registerFactory(
    () => MedicinesBloc(
      getMedicinesUseCase: sl(),
      createMedicineUseCase: sl(),
      updateMedicineUseCase: sl(),
      deleteMedicineUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMedicines(sl()));
  sl.registerLazySingleton(() => CreateMedicine(sl()));
  sl.registerLazySingleton(() => UpdateMedicine(sl()));
  sl.registerLazySingleton(() => DeleteMedicine(sl()));

  // Repository
  sl.registerLazySingleton<MedicinesRepository>(
    () => MedicinesRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<MedicinesLocalDataSource>(
    () => MedicinesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MedicinesRemoteDataSource>(
    () => MedicinesRemoteDataSourceImpl(sl()),
  );

  //! Core & Network
  sl.registerLazySingleton<ConnectivityInfo>(() => ConnectivityInfoImpl(sl()));

  //! Services
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));
  sl.registerLazySingleton<SyncService>(
    () => SyncService(sl(), sl(), sl()),
  );

  //! External
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Dio());
}
