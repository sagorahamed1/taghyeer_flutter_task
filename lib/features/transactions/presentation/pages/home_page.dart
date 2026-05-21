import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spendar/features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/summary_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/arc_meter.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        title: const Text(
          'SpendArc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set budget',
            onPressed: () => _showBudgetDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TransactionBloc>().add(LoadTransactions());
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(),
              const SizedBox(height: 16),
              _ChartCard(),
              const SizedBox(height: 20),
              const Text(
                'Recent',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _TransactionList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: const AddTransactionSheet(),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: context.read<SummaryBloc>().state.budget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                context.read<SummaryBloc>().add(SetBudget(val));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (_, state) {
        final balanceColor = state.balance >= 0
            ? const Color(0xFF06D6A0)
            : const Color(0xFFFF6B6B);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ArcMeter(
                progress: state.usagePercent,
                spent: state.totalSpent,
                budget: state.totalIncome,
              ),
              const SizedBox(height: 4),
              Text(
                'of income spent this month',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(
                    label: 'Income',
                    value: '+\$${state.totalIncome.toStringAsFixed(0)}',
                    color: const Color(0xFF06D6A0),
                  ),
                  _divider(),
                  _Stat(
                    label: 'Balance',
                    value: '${state.balance >= 0 ? '+' : ''}'
                        '\$${state.balance.abs().toStringAsFixed(0)}',
                    color: balanceColor,
                  ),
                  _divider(),
                  _Stat(
                    label: 'Expense',
                    value: '-\$${state.totalSpent.toStringAsFixed(0)}',
                    color: const Color(0xFFFF6B6B),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.grey.shade200,
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (_, state) {
        final weekIncome =
            state.last7DaysIncome.fold(0.0, (s, v) => s + v);
        final weekExpense =
            state.last7DaysExpense.fold(0.0, (s, v) => s + v);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      _LegendDot(
                        color: const Color(0xFF06D6A0),
                        label: '+\$${weekIncome.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 10),
                      _LegendDot(
                        color: const Color(0xFFFF6B6B),
                        label: '-\$${weekExpense.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SpendingChart(
                income: state.last7DaysIncome,
                expenses: state.last7DaysExpense,
              ),
              const SizedBox(height: 8),
              _DayLabels(),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DayLabels extends StatelessWidget {
  static const _days = ['6d', '5d', '4d', '3d', '2d', 'Yst', 'Today'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _days
          .map((d) => Text(
                d,
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ))
          .toList(),
    );
  }
}

class _TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (ctx, state) {
        if (state is TransactionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (ctx, state) {
        if (state is TransactionLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
          );
        }

        final transactions = switch (state) {
          TransactionLoaded(:final transactions) => transactions,
          TransactionError(:final previous) => previous ?? [],
          _ => <dynamic>[],
        };

        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: transactions.map((t) {
            return TransactionTile(
              key: ValueKey(t.id),
              transaction: t,
              onDelete: () => ctx
                  .read<TransactionBloc>()
                  .add(DeleteTransactionEvent(t.id)),
            );
          }).toList(),
        );
      },
    );
  }
}
