import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:driveup/services/expense_service.dart';
import 'package:driveup/services/vehicle_service.dart';

class DespesaPage extends StatefulWidget {
  final String? expenseId;
  final Map<String, dynamic>? initialData;

  const DespesaPage({super.key, this.expenseId, this.initialData});

  @override
  State<DespesaPage> createState() => _DespesaPageState();
}

class _DespesaPageState extends State<DespesaPage> {
  static const yellow = Color(0xFFFFC107);

  final _formKey = GlobalKey<FormState>();

  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSaving = false;

  final List<String> _expenseTypes = [
    'Combustível',
    'Manutenção',
    'Pedágio',
    'Estacionamento',
    'Outros',
  ];

  String? _selectedExpenseType;
  String? _selectedVehicleId;

  /// Agora o método de pagamento é apenas interno (sem campo na tela)
  String _paymentMethod = 'Não informado';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final data = widget.initialData;
    if (data == null) return;

    _selectedVehicleId = data['vehicleId'] as String?;
    _selectedExpenseType = data['expenseType'] as String?;

    final odometer = data['odometer'];
    if (odometer is num) {
      _odometerCtrl.text = odometer.toString().replaceAll('.', ',');
    }

    final value = data['value'];
    if (value is num) {
      _valueCtrl.text = value.toString().replaceAll('.', ',');
    }

    _localCtrl.text = (data['local'] ?? '').toString();
    _obsCtrl.text = (data['observation'] ?? '').toString();

    // mantém o método de pagamento salvo, mas sem opção na UI
    _paymentMethod = (data['paymentMethod'] as String?) ?? 'Não informado';

    final dtRaw = data['dateTime'];
    DateTime? dt;
    if (dtRaw is Timestamp) dt = dtRaw.toDate();
    if (dtRaw is DateTime) dt = dtRaw;

    if (dt != null) {
      _selectedDate = dt;
      _selectedTime = TimeOfDay.fromDateTime(dt);
      _dateCtrl.text =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      _timeCtrl.text =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _odometerCtrl.dispose();
    _valueCtrl.dispose();
    _localCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeCtrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  DateTime _buildDateTime() {
    final now = DateTime.now();
    final date = _selectedDate ?? now;
    final time = _selectedTime ?? TimeOfDay.fromDateTime(now);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione o veículo.')));
      return;
    }

    if (_selectedExpenseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          content: const Text('Preencha o tipo de despesa.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final odometer = ExpenseService.instance.parseBrDouble(
        _odometerCtrl.text,
      );
      final value = ExpenseService.instance.parseBrDouble(_valueCtrl.text);
      final dateTime = _buildDateTime();

      if (widget.expenseId == null) {
        await ExpenseService.instance.createExpense(
          vehicleId: _selectedVehicleId!,
          dateTime: dateTime,
          expenseType: _selectedExpenseType!,
          local: _localCtrl.text.trim(),
          paymentMethod: _paymentMethod,
          observation: _obsCtrl.text.trim().isEmpty
              ? null
              : _obsCtrl.text.trim(),
          odometer: odometer,
          value: value,
        );
      } else {
        await ExpenseService.instance.updateExpense(
          id: widget.expenseId!,
          vehicleId: _selectedVehicleId!,
          dateTime: dateTime,
          expenseType: _selectedExpenseType!,
          local: _localCtrl.text.trim(),
          paymentMethod: _paymentMethod,
          observation: _obsCtrl.text.trim().isEmpty
              ? null
              : _obsCtrl.text.trim(),
          odometer: odometer,
          value: value,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          content: Text(
            widget.expenseId == null
                ? 'Despesa criada com sucesso!'
                : 'Despesa atualizada com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          content: Text('Erro ao salvar despesa: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expenseId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isEdit ? 'EDITAR DESPESA' : 'NOVA DESPESA',
          style: const TextStyle(
            color: Colors.black87,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 4),
            const Text(
              'DESPESA',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: .5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // VEÍCULO
            const Text(
              'VEÍCULO',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: .5,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Vehicle>>(
              stream: VehicleService.instance.vehiclesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Erro ao carregar veículos: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                final vehicles = snapshot.data ?? [];

                if (vehicles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Você ainda não cadastrou nenhum veículo.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonFormField<String>(
                    value: _selectedVehicleId,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.directions_car_filled_outlined,
                        size: 20,
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                      hintText: 'Selecione o veículo',
                    ),
                    items: vehicles
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v.id,
                            child: Text(v.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione o veículo';
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Data / Hora
            Row(
              children: [
                Expanded(
                  child: _GreyField(
                    controller: _dateCtrl,
                    icon: Icons.event,
                    hint: 'Data',
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GreyField(
                    controller: _timeCtrl,
                    icon: Icons.access_time,
                    hint: 'Hora',
                    readOnly: true,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tipo de despesa / Odômetro
            Row(
              children: [
                Expanded(
                  child: _GreyDropdown(
                    icon: Icons.receipt_long_outlined,
                    label: 'Tipo de despesa',
                    value: _selectedExpenseType,
                    items: _expenseTypes,
                    onChanged: (v) {
                      setState(() => _selectedExpenseType = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GreyField(
                    controller: _odometerCtrl,
                    icon: Icons.speed,
                    hint: 'Odômetro',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final txt = value?.trim() ?? '';
                      if (txt.isEmpty) return null; // opcional
                      final parsed = ExpenseService.instance.parseBrDouble(
                        value ?? '',
                      );
                      if (parsed == null) {
                        return 'Informe um número válido';
                      }
                      if (parsed < 0) return 'Valor não pode ser negativo';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Valor
            _GreyField(
              controller: _valueCtrl,
              icon: Icons.attach_money,
              hint: 'Valor da despesa (R\$)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final txt = value?.trim() ?? '';
                if (txt.isEmpty) return 'Informe o valor da despesa';

                final parsed = ExpenseService.instance.parseBrDouble(txt);
                if (parsed == null) return 'Valor inválido';
                if (parsed < 0) return 'Não pode ser negativo';

                return null;
              },
            ),
            const SizedBox(height: 12),

            // Local
            _GreyField(
              controller: _localCtrl,
              icon: Icons.location_on_outlined,
              hint: 'Local',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o local da despesa';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Observação
            _GreyField(
              controller: _obsCtrl,
              icon: Icons.notes_outlined,
              hint: 'Observação',
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            Center(
              child: SizedBox(
                width: 220,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black87,
                    shape: const StadiumBorder(),
                    elevation: 1.5,
                  ),
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'ATUALIZAR' : 'SALVAR',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: .6,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _GreyField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final int maxLines;

  const _GreyField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _GreyDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _GreyDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          icon: Icon(icon, size: 20, color: Colors.black54),
          border: InputBorder.none,
          hintText: label,
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
