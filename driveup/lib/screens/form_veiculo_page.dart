import 'package:flutter/material.dart';

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
            ),
            _TextField(label: 'Nome do veículo', icon: Icons.directions_car),
            _DropdownField(
              label: 'Marca',
              icon: Icons.local_offer_outlined,
              value: marca,
              items: const ['Volkswagen', 'Honda', 'Toyota', 'Chevrolet'],
              onChanged: (v) => setState(() => marca = v),
            ),
            _TextField(label: 'Modelo', icon: Icons.settings_outlined),
            const SizedBox(height: 8),
            const _SectionTitle('ADMINISTRATIVO'),
            Row(
              children: const [
                Expanded(
                  child: _TextField(
                    label: 'Placa',
                    icon: Icons.confirmation_number_outlined,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _TextField(
                    label: 'Ano',
                    icon: Icons.calendar_today_outlined,
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
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: _TextField(
                    label: 'Volume do Tanque',
                    icon: Icons.local_drink_outlined,
                  ),
                ),
              ],
            ),
            const _TextField(
              label: 'Chassi (Opcional)',
              icon: Icons.code_outlined,
            ),
            const _TextField(
              label: 'Renavam (Opcional)',
              icon: Icons.qr_code_2_outlined,
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: salvar veículo
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veículo salvo com sucesso!'),
                        ),
                      );
                    }
                  },
                  child: const Text(
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
}

/// ---------- Campos reutilizáveis ----------

class _TextField extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TextField({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
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

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
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
