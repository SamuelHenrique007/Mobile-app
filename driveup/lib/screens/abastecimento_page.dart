import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:driveup/services/fuel_service.dart';
import 'package:driveup/services/vehicle_service.dart';
import 'package:driveup/widgets/profile_avatar_button.dart';
import 'package:driveup/screens/perfil_page.dart';

class AbastecimentoPage extends StatefulWidget {
  /// null = novo abastecimento
  final String? fuelId;

  /// Dados iniciais para edição (vêm do VehicleHistoryPage)
  final Map<String, dynamic>? initialData;

  const AbastecimentoPage({super.key, this.fuelId, this.initialData});

  @override
  State<AbastecimentoPage> createState() => _AbastecimentoPageState();
}

class _AbastecimentoPageState extends State<AbastecimentoPage> {
  static const yellow = Color(0xFFFFC107);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  final _fuelPriceCtrl = TextEditingController(); // valor do litro
  final _totalPriceCtrl = TextEditingController(); // valor total em R$
  final _litersCtrl = TextEditingController(); // litros
  final _stationCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSaving = false;

  // Tipo de combustível
  String _fuelType = 'Gasolina';
  final _fuelTypes = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];

  // Veículo selecionado
  String? _selectedVehicleId;
  String? _selectedVehicleName; // nome do veículo selecionado

  @override
  void initState() {
    super.initState();

    _fuelPriceCtrl.addListener(_recalculateLiters);
    _totalPriceCtrl.addListener(_recalculateLiters);

    _loadInitialData();
  }

  void _loadInitialData() {
    final data = widget.initialData;
    if (data == null) return;

    // vehicleId
    _selectedVehicleId = data['vehicleId'] as String?;

    // tipo de combustível
    final fuelTypeRaw = data['fuelType'] as String?;
    if (fuelTypeRaw != null && _fuelTypes.contains(fuelTypeRaw)) {
      _fuelType = fuelTypeRaw;
    }

    // valores numéricos
    final odometer = data['odometer'];
    if (odometer is num) {
      _odometerCtrl.text = odometer.toString().replaceAll('.', ',');
    }

    final pricePerLiter = data['pricePerLiter'];
    if (pricePerLiter is num) {
      _fuelPriceCtrl.text = pricePerLiter.toString().replaceAll('.', ',');
    }

    final totalPrice = data['totalPrice'];
    if (totalPrice is num) {
      _totalPriceCtrl.text = totalPrice.toString().replaceAll('.', ',');
    }

    final liters = data['liters'];
    if (liters is num) {
      _litersCtrl.text = liters.toString().replaceAll('.', ',');
    }

    // posto
    _stationCtrl.text = (data['station'] ?? '').toString();

    // data/hora
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

    _fuelPriceCtrl.removeListener(_recalculateLiters);
    _fuelPriceCtrl.dispose();

    _totalPriceCtrl.removeListener(_recalculateLiters);
    _totalPriceCtrl.dispose();

    _litersCtrl.dispose();
    _stationCtrl.dispose();
    super.dispose();
  }

  /// Converte número no estilo brasileiro "4,49" -> 4.49
  double? _parseBrNumber(String text) {
    if (text.trim().isEmpty) return null;
    var cleaned = text.trim();

    // remove separador de milhar: 1.234,56 -> 1234,56
    cleaned = cleaned.replaceAll('.', '');
    // troca vírgula por ponto: 1234,56 -> 1234.56
    cleaned = cleaned.replaceAll(',', '.');

    return double.tryParse(cleaned);
  }

  /// Recalcula automaticamente o campo "Litros" quando
  /// "Valor combustível" e "Valor total" forem preenchidos
  void _recalculateLiters() {
    final price = _parseBrNumber(_fuelPriceCtrl.text); // valor por litro
    final total = _parseBrNumber(_totalPriceCtrl.text); // quanto pagou

    if (price == null || price <= 0 || total == null) {
      if (_litersCtrl.text.isNotEmpty) {
        _litersCtrl.text = '';
      }
      return;
    }

    final liters = total / price;
    final formatted = liters.toStringAsFixed(2).replaceAll('.', ',');

    if (_litersCtrl.text != formatted) {
      _litersCtrl.text = formatted;
    }
  }

  DateTime _buildDateTime() {
    final now = DateTime.now();
    final date = _selectedDate ?? now;
    final time = _selectedTime ?? TimeOfDay.fromDateTime(now);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

  Future<void> _onSave() async {
    if (_isSaving) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedVehicleId == null || _selectedVehicleName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione o veículo.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateTime = _buildDateTime();

      final odometer = _parseBrNumber(_odometerCtrl.text);
      final pricePerLiter = _parseBrNumber(_fuelPriceCtrl.text);
      final totalPrice = _parseBrNumber(_totalPriceCtrl.text);
      final liters = _parseBrNumber(_litersCtrl.text);
      final station = _stationCtrl.text.trim().isEmpty
          ? null
          : _stationCtrl.text.trim();

      if (widget.fuelId == null) {
        // novo
        await FuelService.instance.createFuel(
          vehicleId: _selectedVehicleId!,
          vehicleName: _selectedVehicleName!,
          dateTime: dateTime,
          fuelType: _fuelType,
          odometer: odometer,
          pricePerLiter: pricePerLiter,
          totalPrice: totalPrice,
          liters: liters,
          station: station,
        );
      } else {
        // edição
        await FuelService.instance.updateFuel(
          id: widget.fuelId!,
          vehicleId: _selectedVehicleId!,
          dateTime: dateTime,
          fuelType: _fuelType,
          odometer: odometer,
          pricePerLiter: pricePerLiter,
          totalPrice: totalPrice,
          liters: liters,
          station: station,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          content: Text(
            widget.fuelId == null
                ? 'Abastecimento salvo com sucesso!'
                : 'Abastecimento atualizado com sucesso!',
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
          content: Text('Erro ao salvar abastecimento: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.fuelId != null;

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
          isEdit ? 'EDITAR ABASTECIMENTO' : 'NOVO ABASTECIMENTO',
          style: const TextStyle(
            color: Colors.black87,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilPage()),
                );
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
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
              'ABASTECIMENTO',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: .5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // ===== VEÍCULO =====
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

                // se estamos editando e ainda não definimos o nome, tenta buscar
                if (_selectedVehicleId != null &&
                    _selectedVehicleName == null) {
                  final v = vehicles.firstWhere(
                    (veh) => veh.id == _selectedVehicleId,
                    orElse: () => vehicles.first,
                  );
                  _selectedVehicleName = v.name;
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

                        if (value != null) {
                          final v = vehicles.firstWhere(
                            (veh) => veh.id == value,
                            orElse: () => vehicles.first,
                          );
                          _selectedVehicleName = v.name;
                        } else {
                          _selectedVehicleName = null;
                        }
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

            // Linha 1: Data / Hora
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
                      if (value == null || value.isEmpty) {
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a hora';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Linha 2: Tipo combustível / Hodômetro
            Row(
              children: [
                Expanded(
                  child: _GreyDropdown(
                    icon: Icons.local_gas_station_outlined,
                    value: _fuelType,
                    items: _fuelTypes,
                    onChanged: (v) {
                      if (v != null) setState(() => _fuelType = v);
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Linha 3: valor combust., valor total, litros
            Row(
              children: [
                Expanded(
                  child: _GreyField(
                    controller: _fuelPriceCtrl,
                    icon: Icons.local_gas_station,
                    hint: 'Valor combustível',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GreyField(
                    controller: _totalPriceCtrl,
                    icon: Icons.attach_money,
                    hint: 'Valor total',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o valor total';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GreyField(
                    controller: _litersCtrl,
                    icon: Icons.local_drink_outlined,
                    hint: 'Litros',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Linha 4: Posto (full width)
            _GreyField(
              controller: _stationCtrl,
              icon: Icons.local_gas_station,
              hint: 'Posto',
            ),

            const SizedBox(height: 32),

            // Botão SALVAR / ATUALIZAR
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
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _GreyDropdown({
    required this.icon,
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
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
