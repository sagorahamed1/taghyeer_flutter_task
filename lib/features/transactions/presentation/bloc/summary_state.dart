part of 'summary_bloc.dart';

class SummaryState extends Equatable {
  final double totalIncome;
  final double totalSpent;
  final double budget;
  final List<double> last7DaysIncome;
  final List<double> last7DaysExpense;

  const SummaryState({
    this.totalIncome = 0,
    this.totalSpent = 0,
    this.budget = 3000,
    this.last7DaysIncome = const [0, 0, 0, 0, 0, 0, 0],
    this.last7DaysExpense = const [0, 0, 0, 0, 0, 0, 0],
  });

  double get balance => totalIncome - totalSpent;

  /// ******** arc shows what fraction of income was spent this month**
  double get usagePercent =>
      totalIncome == 0 ? 0 : (totalSpent / totalIncome).clamp(0.0, 1.0);

  SummaryState copyWith({
    double? totalIncome,
    double? totalSpent,
    double? budget,
    List<double>? last7DaysIncome,
    List<double>? last7DaysExpense,
  }) {
    return SummaryState(
      totalIncome: totalIncome ?? this.totalIncome,
      totalSpent: totalSpent ?? this.totalSpent,
      budget: budget ?? this.budget,
      last7DaysIncome: last7DaysIncome ?? this.last7DaysIncome,
      last7DaysExpense: last7DaysExpense ?? this.last7DaysExpense,
    );
  }

  @override
  List<Object?> get props => [
        totalIncome,
        totalSpent,
        budget,
        last7DaysIncome,
        last7DaysExpense,
      ];
}
