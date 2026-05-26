import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitialState extends DashboardState {
  const DashboardInitialState();
}

class DashboardLoadingState extends DashboardState {
  const DashboardLoadingState();
}

class DashboardLoadedState extends DashboardState {
  final DashboardData data;
  const DashboardLoadedState(this.data);
}

class DashboardErrorState extends DashboardState {
  final String message;
  const DashboardErrorState(this.message);
}
