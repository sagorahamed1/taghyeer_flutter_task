part of 'summary_bloc.dart';

class SummaryState extends Equatable {
  final double totalSpent;
  final double budget;
  final List<double> last7Days;

  const SummaryState({
    this.totalSpent = 0,
    this.budget = 1000,
    this.last7Days = const [0, 0, 0, 0, 0, 0, 0],
  });

  double get usagePercent =>
      budget == 0 ? 0 : (totalSpent / budget).clamp(0.0, 1.0);

  double get remaining => (budget - totalSpent).clamp(0.0, budget);

  SummaryState copyWith({
    double? totalSpent,
    double? budget,
    List<double>? last7Days,
  }) {
    return SummaryState(
      totalSpent: totalSpent ?? this.totalSpent,
      budget: budget ?? this.budget,
      last7Days: last7Days ?? this.last7Days,
    );
  }

  @override
  List<Object?> get props => [totalSpent, budget, last7Days];
}
