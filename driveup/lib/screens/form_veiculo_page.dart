import 'package:flutter/material.dart';
import 'package:driveup/services/vehicle_service.dart';

class FormVeiculoPage extends StatefulWidget {
  const FormVeiculoPage({super.key});

  @override
  State<FormVeiculoPage> createState() => _FormVeiculoPageState();
}

class _FormVeiculoPageState extends State<FormVeiculoPage> {
  final _formKey = GlobalKey<FormState>();

  String? tipo;
  String? marca;
  String? combustivel;

  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  final _tanqueController = TextEditingController();
  final _chassiController = TextEditingController();
  final _renavamController = TextEditingController();
  final _corController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _tanqueController.dispose();
    _chassiController.dispose();
    _renavamController.dispose();
    _corController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'INICIO',
          style: TextStyle(color: Colors.black87, letterSpacing: 1),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            const _SectionTitle('VEÍCULO'),
            _DropdownField(
              label: 'Tipo de Veículo',
              icon: Icons.directions_car_outlined,
              value: tipo,
              items: const ['Carro', 'Moto', 'Caminhão'],
              onChanged: (v) => setState(() => tipo = v),
              validator: (v) => v == null ? 'Selecione o tipo' : null,
            ),
            _TextField(
              label: 'Nome do veículo',
              icon: Icons.directions_car,
              controller: _nomeController,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o nome do veículo' : null,
            ),
            _DropdownField(
              label: 'Marca',
              icon: Icons.local_offer_outlined,
              value: marca,
              items: const ['Volkswagen', 'Honda', 'Toyota', 'Chevrolet'],
              onChanged: (v) => setState(() => marca = v),
              validator: (v) => v == null ? 'Selecione a marca' : null,
            ),
            _TextField(
              label: 'Modelo',
              icon: Icons.settings_outlined,
              controller: _modeloController,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o modelo' : null,
            ),
            _TextField(
              label: 'Cor',
              icon: Icons.color_lens_outlined,
              controller: _corController,
              validator: (v) => v == null || v.isEmpty ? 'Informe a cor' : null,
            ),
            const SizedBox(height: 8),
            const _SectionTitle('ADMINISTRATIVO'),
            Row(
              children: [
                Expanded(
                  child: _TextField(
                    label: 'Placa',
                    icon: Icons.confirmation_number_outlined,
                    controller: _placaController,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe a placa' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TextField(
                    label: 'Ano',
                    icon: Icons.calendar_today_outlined,
                    controller: _anoController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe o ano' : null,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    label: 'Combustível',
                    icon: Icons.local_gas_station_outlined,
                    value: combustivel,
                    items: const ['Gasolina', 'Etanol', 'Diesel', 'Elétrico'],
                    onChanged: (v) => setState(() => combustivel = v),
                    validator: (v) =>
                        v == null ? 'Selecione o combustível' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TextField(
                    label: 'Volume do Tanque',
                    icon: Icons.local_drink_outlined,
                    controller: _tanqueController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _TextField(
              label: 'Chassi (Opcional)',
              icon: Icons.code_outlined,
              controller: _chassiController,
            ),
            _TextField(
              label: 'Renavam (Opcional)',
              icon: Icons.qr_code_2_outlined,
              controller: _renavamController,
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 250,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black87,
                    shape: const StadiumBorder(),
                    elevation: 1.5,
                  ),
                  onPressed: _salvando ? null : _salvarVeiculo,
                  child: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'SALVAR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomBarVeiculosSelected(),
    );
  }

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final vehicle = Vehicle(
        id: '',
        type: tipo!,
        name: _nomeController.text.trim(),
        brand: marca!,
        model: _modeloController.text.trim(),
        year: _anoController.text.trim(),
        color: _corController.text.trim(),
        plate: _placaController.text.trim(),
        fuel: combustivel!,
        tankVolume: _tanqueController.text.trim(),
        chassis: _chassiController.text.trim().isEmpty
            ? null
            : _chassiController.text.trim(),
        renavam: _renavamController.text.trim().isEmpty
            ? null
            : _renavamController.text.trim(),
      );

      await VehicleService.instance.addVehicle(vehicle);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo salvo com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar veículo: $e')));
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }
}

/// ---------- Campos reutilizáveis ----------

class _TextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _TextField({
    required this.label,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 22),
          hintText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          decoration: InputDecoration(
            icon: Icon(icon, size: 22),
            hintText: label,
            border: InputBorder.none,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// ---------- Bottom bar ----------
class _BottomBarVeiculosSelected extends StatelessWidget {
  const _BottomBarVeiculosSelected();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 76,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                icon: Icons.home_outlined,
                label: 'Início',
                onTap: () {},
              ),
              _BottomItem(
                icon: Icons.receipt_long_outlined,
                label: 'Registros',
                onTap: () {},
              ),
              const SizedBox(width: 56),
              _BottomItem(
                icon: Icons.notifications_none,
                label: 'Alertas',
                onTap: () {},
              ),
              _BottomItem(
                icon: Icons.directions_car_filled_outlined,
                label: 'Veículos',
                selected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFFC107) : Colors.black54;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
