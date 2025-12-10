import 'package:flutter/material.dart';
import 'package:driveup/services/reminder_service.dart';
import 'package:driveup/services/vehicle_service.dart';

class ReminderFormPage extends StatefulWidget {
  const ReminderFormPage({super.key});

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  static const yellow = Color(0xFFFFC107);

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _selectedVehicleId;
  String? _selectedVehicleName;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
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

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isSaving = true);

    try {
      final dateTime = _buildDateTime();

      await ReminderService.instance.createReminder(
        title: _titleCtrl.text.trim(),
        dateTime: dateTime,
        vehicleId: _selectedVehicleId,
        vehicleName: _selectedVehicleName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembrete criado com sucesso!'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.zero,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar lembrete: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'NOVO LEMBRETE',
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 4),
            const Text(
              'LEMBRETE',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: .5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            _GreyField(
              controller: _titleCtrl,
              icon: Icons.notifications_active_outlined,
              hint: 'Título (ex: Revisão, IPVA, CNH...)',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe um título';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a data';
                      }
                      return null;
                    },
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

            // Veículo opcional
            StreamBuilder<List<Vehicle>>(
              stream: VehicleService.instance.vehiclesStream(),
              builder: (context, snapshot) {
                final vehicles = snapshot.data ?? [];

                return _GreyDropdown(
                  icon: Icons.directions_car_outlined,
                  value: _selectedVehicleId,
                  hint: 'Vincular a um veículo (opcional)',
                  items: vehicles
                      .map(
                        (v) => DropdownMenuItem<String>(
                          value: v.id,
                          child: Text(v.name),
                        ),
                      )
                      .toList(),
                  onChanged: (vId) {
                    setState(() {
                      _selectedVehicleId = vId;
                      if (vId == null) {
                        _selectedVehicleName = null;
                      } else {
                        final v = vehicles.firstWhere(
                          (e) => e.id == vId,
                          orElse: () => vehicles.first,
                        );
                        _selectedVehicleName = v.name;
                      }
                    });
                  },
                );
              },
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
                      : const Text(
                          'SALVAR',
                          style: TextStyle(
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

  const _GreyField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      validator: validator,
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
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _GreyDropdown({
    required this.icon,
    required this.value,
    required this.hint,
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
          hintText: hint,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
