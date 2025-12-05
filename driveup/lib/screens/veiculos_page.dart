import 'package:flutter/material.dart';
import 'package:driveup/services/vehicle_service.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  static const yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<Vehicle>>(
        stream: VehicleService.instance.vehiclesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar veículos:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final veiculos = snapshot.data ?? [];

          if (veiculos.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                const _SectionTitle('VEÍCULOS'),
                const SizedBox(height: 16),
                const Text(
                  'Você ainda não cadastrou nenhum veículo.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black87,
                        shape: const StadiumBorder(),
                        elevation: 1.5,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/formVeiculo');
                      },
                      child: const Text(
                        'ADICIONAR VEÍCULO',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 90),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              const _SectionTitle('VEÍCULOS'),
              for (final v in veiculos)
                VehicleCard(
                  icon: v.type == 'Moto'
                      ? Icons.motorcycle_outlined
                      : Icons.directions_car_outlined,
                  titulo: v.name,
                  modelo: v.model,
                  ano: v.year,
                  cor: v.color,
                  marca: v.brand,
                  onEdit: () {
                    // TODO: abrir tela de edição com dados do veículo
                  },
                  onTap: () {
                    // TODO: abrir detalhes do veículo
                  },
                ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black87,
                      shape: const StadiumBorder(),
                      elevation: 1.5,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/formVeiculo');
                    },
                    child: const Text(
                      'ADICIONAR VEÍCULO',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        onPressed: () {
          Navigator.pushNamed(context, '/formVeiculo');
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomBarVeiculosSelected(),
    );
  }
}

/// Simple section title used in the list
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// ---------- Card do veículo ----------
class VehicleCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String modelo;
  final String ano;
  final String cor;
  final String marca;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.modelo,
    required this.ano,
    required this.cor,
    required this.marca,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = Colors.black.withOpacity(.65);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 18,
                      runSpacing: 4,
                      children: [
                        _mini('Modelo', modelo, subtle),
                        _mini('Ano', ano, subtle),
                        _mini('Cor', cor, subtle),
                        _mini('Marca', marca, subtle),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: Colors.black54,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mini(String label, String value, Color color) {
    return Text(
      '$label: $value',
      style: TextStyle(fontSize: 12.5, color: color),
    );
  }
}

/// ---------- Bottom bar com “Veículos” selecionado ----------
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
                selected: true, // amarelo
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
