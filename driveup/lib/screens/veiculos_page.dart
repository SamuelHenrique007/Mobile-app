import 'package:flutter/material.dart';
import 'package:driveup/services/vehicle_service.dart';
import 'package:driveup/screens/sidemenu_page.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  Future<void> _confirmarExclusao(Vehicle v) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir veículo'),
            content: Text('Deseja excluir o veículo "${v.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    try {
      await VehicleService.instance.deleteVehicle(v.id);
      if (!mounted) return;

      // ✅ SnackBar flutuante (não empurra FAB / bottom bar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veículo excluído.'),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir veículo: $e'),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SideMenuPage()));
          },
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
              child: Text(
                'Erro ao carregar veículos:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final veiculos = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              const _SectionTitle('VEÍCULOS'),

              if (veiculos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Você ainda não cadastrou nenhum veículo.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),

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
                    Navigator.pushNamed(
                      context,
                      '/formVeiculo',
                      arguments: v, // passa o Vehicle para edição
                    );
                  },
                  onDelete: () => _confirmarExclusao(v),
                  onTap: () {
                    // se quiser abrir detalhes depois
                  },
                ),

              const SizedBox(height: 8),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
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
    );
  }
}

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

class VehicleCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String modelo;
  final String ano;
  final String cor;
  final String marca;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
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
    this.onDelete,
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
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Excluir',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.black54,
                ),
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
