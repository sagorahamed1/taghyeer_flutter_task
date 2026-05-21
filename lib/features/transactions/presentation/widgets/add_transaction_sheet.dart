import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = 'Food';
  DateTime _date = DateTime.now();

  static const _expenseCategories = [
    'Food', 'Transport', 'Shopping', 'Health', 'Entertainment',
  ];
  static const _incomeCategories = [
    'Salary', 'Freelance', 'Investment', 'Gift', 'Other',
  ];

  List<String> get _categories =>
      _type == TransactionType.expense ? _expenseCategories : _incomeCategories;

  Color get _activeColor =>
      _type == TransactionType.expense
          ? const Color(0xFFFF6B6B)
          : const Color(0xFF06D6A0);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType t) {
    setState(() {
      _type = t;
      _category = _categories.first;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      category: _category,
      type: _type,
      date: _date,
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TypeBtn(
                    label: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    selected: _type == TransactionType.expense,
                    activeColor: const Color(0xFFFF6B6B),
                    onTap: () => _onTypeChanged(TransactionType.expense),
                  ),
                  _TypeBtn(
                    label: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    selected: _type == TransactionType.income,
                    activeColor: const Color(0xFF06D6A0),
                    onTap: () => _onTypeChanged(TransactionType.income),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDeco('Title', Icons.edit_outlined),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountCtrl,
              decoration: _inputDeco('Amount (\$)', Icons.attach_money),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter an amount';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final selected = cat == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: _activeColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: selected ? _activeColor : Colors.grey[700],
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _activeColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _type == TransactionType.expense
                      ? 'Save Expense'
                      : 'Save Income',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
