import 'package:flutter/material.dart';
import 'package:driveup/screens/sidemenu_page.dart';

class AbastecimentoPage extends StatefulWidget {
  const AbastecimentoPage({super.key});

  @override
  State<AbastecimentoPage> createState() => _AbastecimentoPageState();
}

class _AbastecimentoPageState extends State<AbastecimentoPage> {
  final _dateCtrl = TextEditingController(text: '04/11/2025');
  final _timeCtrl = TextEditingController(text: '22:59');
  final _odometerCtrl = TextEditingController();
  final _fuelPriceCtrl = TextEditingController(text: '4,49');
  final _totalPriceCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();

  String _fuelType = 'Gasolina';
  final _fuelTypes = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _odometerCtrl.dispose();
    _fuelPriceCtrl.dispose();
    _totalPriceCtrl.dispose();
    _litersCtrl.dispose();
    _stationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
             Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SideMenuPage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'INICIO',
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GreyField(
                  controller: _totalPriceCtrl,
                  icon: Icons.attach_money,
                  hint: 'Valor total',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GreyField(
                  controller: _litersCtrl,
                  icon: Icons.local_drink_outlined,
                  hint: 'Litros',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                onPressed: _onSave,
                child: const Text(
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
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() {
        _timeCtrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _onSave() {
    // TODO: salvar no backend / firestore / api
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abastecimento salvo!')),
    );
  }
}

/// ====== widgets reutilizáveis ======

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
