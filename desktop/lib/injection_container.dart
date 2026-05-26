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

import 'package:desktop/features/customers/data/datasources/customers_local_data_source.dart';
import 'package:desktop/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:desktop/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:desktop/features/customers/domain/repositories/customers_repository.dart';
import 'package:desktop/features/customers/domain/usecases/create_customer.dart';
import 'package:desktop/features/customers/domain/usecases/delete_customer.dart';
import 'package:desktop/features/customers/domain/usecases/get_customers.dart';
import 'package:desktop/features/customers/domain/usecases/update_customer.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_bloc.dart';

import 'package:desktop/features/inventory/data/datasources/batches_local_data_source.dart';
import 'package:desktop/features/inventory/data/datasources/batches_remote_data_source.dart';
import 'package:desktop/features/inventory/data/repositories/batches_repository_impl.dart';
import 'package:desktop/features/inventory/domain/repositories/batches_repository.dart';
import 'package:desktop/features/inventory/domain/usecases/create_batch.dart';
import 'package:desktop/features/inventory/domain/usecases/delete_batch.dart';
import 'package:desktop/features/inventory/domain/usecases/get_batches.dart';
import 'package:desktop/features/inventory/domain/usecases/update_batch.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_bloc.dart';

import 'package:desktop/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:desktop/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:desktop/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:desktop/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:desktop/features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:desktop/features/purchases/data/datasources/purchase_invoices_local_data_source.dart';
import 'package:desktop/features/purchases/data/datasources/purchase_invoices_remote_data_source.dart';
import 'package:desktop/features/purchases/data/repositories/purchase_invoices_repository_impl.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_invoices_repository.dart';
import 'package:desktop/features/purchases/domain/usecases/create_purchase_invoice.dart';
import 'package:desktop/features/purchases/domain/usecases/get_purchase_invoices.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_bloc.dart';

import 'package:desktop/features/purchases/data/datasources/purchase_returns_local_data_source.dart';
import 'package:desktop/features/purchases/data/datasources/purchase_returns_remote_data_source.dart';
import 'package:desktop/features/purchases/data/repositories/purchase_returns_repository_impl.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_returns_repository.dart';
import 'package:desktop/features/purchases/domain/usecases/create_purchase_return.dart';
import 'package:desktop/features/purchases/domain/usecases/get_purchase_returns.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_bloc.dart';

import 'package:desktop/features/sales/data/datasources/sales_invoices_local_data_source.dart';
import 'package:desktop/features/sales/data/datasources/sales_invoices_remote_data_source.dart';
import 'package:desktop/features/sales/data/datasources/sales_returns_local_data_source.dart';
import 'package:desktop/features/sales/data/datasources/sales_returns_remote_data_source.dart';
import 'package:desktop/features/sales/data/repositories/sales_invoices_repository_impl.dart';
import 'package:desktop/features/sales/data/repositories/sales_returns_repository_impl.dart';
import 'package:desktop/features/sales/domain/repositories/sales_invoices_repository.dart';
import 'package:desktop/features/sales/domain/repositories/sales_returns_repository.dart';
import 'package:desktop/features/sales/domain/usecases/create_sales_invoice.dart';
import 'package:desktop/features/sales/domain/usecases/create_sales_return.dart';
import 'package:desktop/features/sales/domain/usecases/get_sales_invoices.dart';
import 'package:desktop/features/sales/domain/usecases/get_sales_returns.dart';
import 'package:desktop/features/sales/domain/usecases/update_sales_invoice.dart';
import 'package:desktop/features/sales/domain/usecases/delete_sales_invoice.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Dashboard
  // BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardDataUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );

  //! Features - Purchases (Invoices & Returns)
  // BLoC
  sl.registerFactory(
    () => PurchaseInvoicesBloc(
      getPurchaseInvoicesUseCase: sl(),
      createPurchaseInvoiceUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => PurchaseReturnsBloc(
      getPurchaseReturnsUseCase: sl(),
      createPurchaseReturnUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPurchaseInvoices(sl()));
  sl.registerLazySingleton(() => CreatePurchaseInvoice(sl()));
  sl.registerLazySingleton(() => GetPurchaseReturns(sl()));
  sl.registerLazySingleton(() => CreatePurchaseReturn(sl()));

  // Repository
  sl.registerLazySingleton<PurchaseInvoicesRepository>(
    () => PurchaseInvoicesRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );
  sl.registerLazySingleton<PurchaseReturnsRepository>(
    () => PurchaseReturnsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PurchaseInvoicesLocalDataSource>(
    () => PurchaseInvoicesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PurchaseInvoicesRemoteDataSource>(
    () => PurchaseInvoicesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PurchaseReturnsLocalDataSource>(
    () => PurchaseReturnsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PurchaseReturnsRemoteDataSource>(
    () => PurchaseReturnsRemoteDataSourceImpl(sl()),
  );

  //! Features - Sales (Invoices & Returns)
  // BLoC
  sl.registerFactory(
    () => SalesInvoicesBloc(
      getSalesInvoicesUseCase: sl(),
      createSalesInvoiceUseCase: sl(),
      updateSalesInvoiceUseCase: sl(),
      deleteSalesInvoiceUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SalesReturnsBloc(
      getSalesReturnsUseCase: sl(),
      createSalesReturnUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSalesInvoices(sl()));
  sl.registerLazySingleton(() => CreateSalesInvoice(sl()));
  sl.registerLazySingleton(() => UpdateSalesInvoice(sl()));
  sl.registerLazySingleton(() => DeleteSalesInvoice(sl()));
  sl.registerLazySingleton(() => GetSalesReturns(sl()));
  sl.registerLazySingleton(() => CreateSalesReturn(sl()));

  // Repository
  sl.registerLazySingleton<SalesInvoicesRepository>(
    () => SalesInvoicesRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );
  sl.registerLazySingleton<SalesReturnsRepository>(
    () => SalesReturnsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SalesInvoicesLocalDataSource>(
    () => SalesInvoicesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SalesInvoicesRemoteDataSource>(
    () => SalesInvoicesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SalesReturnsLocalDataSource>(
    () => SalesReturnsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SalesReturnsRemoteDataSource>(
    () => SalesReturnsRemoteDataSourceImpl(sl(), sl()),
  );

  //! Features - Inventory (Batches)
  // BLoC
  sl.registerFactory(
    () => BatchesBloc(
      getBatchesUseCase: sl(),
      createBatchUseCase: sl(),
      updateBatchUseCase: sl(),
      deleteBatchUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBatches(sl()));
  sl.registerLazySingleton(() => CreateBatch(sl()));
  sl.registerLazySingleton(() => UpdateBatch(sl()));
  sl.registerLazySingleton(() => DeleteBatch(sl()));

  // Repository
  sl.registerLazySingleton<BatchesRepository>(
    () => BatchesRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<BatchesLocalDataSource>(
    () => BatchesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BatchesRemoteDataSource>(
    () => BatchesRemoteDataSourceImpl(sl()),
  );

  //! Features - Customers
  // BLoC
  sl.registerFactory(
    () => CustomersBloc(
      getCustomersUseCase: sl(),
      createCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => CreateCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCustomer(sl()));

  // Repository
  sl.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivityInfo: sl(),
      databaseService: sl(),
      syncService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CustomersLocalDataSource>(
    () => CustomersLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CustomersRemoteDataSource>(
    () => CustomersRemoteDataSourceImpl(sl()),
  );

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

  // Pre-initialize services and load custom API Base URL from local SQLite settings
  final dbService = sl<DatabaseService>();
  final apiService = sl<ApiService>();
  await apiService.loadCustomBaseUrl(dbService);
}
