import 'package:flutter/material.dart';
import 'package:driveup/screens/sidemenu_page.dart';
import 'package:driveup/services/vehicle_service.dart';
import 'package:driveup/services/fuel_service.dart';

class AbastecimentoPage extends StatefulWidget {
  const AbastecimentoPage({super.key});

  @override
  State<AbastecimentoPage> createState() => _AbastecimentoPageState();
}

class _AbastecimentoPageState extends State<AbastecimentoPage> {
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  final _fuelPriceCtrl = TextEditingController(); // valor do litro
  final _totalPriceCtrl = TextEditingController(); // valor total em R$
  final _litersCtrl = TextEditingController(); // litros
  final _stationCtrl = TextEditingController();

  String _fuelType = 'Gasolina';
  final _fuelTypes = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];

  String? _selectedVehicleId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fuelPriceCtrl.addListener(_recalculateLiters);
    _totalPriceCtrl.addListener(_recalculateLiters);
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
    cleaned = cleaned.replaceAll('.', '');
    cleaned = cleaned.replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  /// Recalcula litros = total / preço
  void _recalculateLiters() {
    final price = _parseBrNumber(_fuelPriceCtrl.text);
    final total = _parseBrNumber(_totalPriceCtrl.text);

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

  DateTime _buildDateTimeFromFields() {
    final now = DateTime.now();

    int day = now.day;
    int month = now.month;
    int year = now.year;

    if (_dateCtrl.text.isNotEmpty) {
      final parts = _dateCtrl.text.split('/');
      if (parts.length == 3) {
        day = int.tryParse(parts[0]) ?? day;
        month = int.tryParse(parts[1]) ?? month;
        year = int.tryParse(parts[2]) ?? year;
      }
    }

    int hour = now.hour;
    int minute = now.minute;

    if (_timeCtrl.text.isNotEmpty) {
      final parts = _timeCtrl.text.split(':');
      if (parts.length == 2) {
        hour = int.tryParse(parts[0]) ?? hour;
        minute = int.tryParse(parts[1]) ?? minute;
      }
    }

    return DateTime(year, month, day, hour, minute);
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione o veículo.')));
      return;
    }

    final totalPrice = _parseBrNumber(_totalPriceCtrl.text);
    final liters = _parseBrNumber(_litersCtrl.text);

    if (totalPrice == null || liters == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe valor total e litros (ou valor do litro).'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateTime = _buildDateTimeFromFields();
      final pricePerLiter = _parseBrNumber(_fuelPriceCtrl.text);
      final odometer = _parseBrNumber(_odometerCtrl.text);
      final station = _stationCtrl.text.trim().isEmpty
          ? null
          : _stationCtrl.text.trim();

      await FuelService.instance.createFuel(
        vehicleId: _selectedVehicleId!,
        dateTime: dateTime,
        fuelType: _fuelType,
        odometer: odometer,
        pricePerLiter: pricePerLiter,
        totalPrice: totalPrice,
        liters: liters,
        station: station,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abastecimento salvo com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar abastecimento: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

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
          'NOVO ABASTECIMENTO',
          style: TextStyle(
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
      body: ListView(
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

          // Botão SALVAR
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
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        _timeCtrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
}

class _GreyField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const _GreyField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
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
