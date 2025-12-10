import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveup/screens/veiculos_page.dart';
import 'package:driveup/navigation/main_navigation.dart'; 
import 'package:driveup/screens/historico_abastecimento_page.dart';
import 'package:driveup/screens/sobre_page.dart';
import 'package:driveup/screens/postos_page.dart';
import 'package:driveup/screens/locais_page.dart';
import 'package:driveup/screens/historico_despesa_page.dart';


class SideMenuPage extends StatelessWidget {
  const SideMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: .5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          const _UserHeader(),
          const SizedBox(height: 16),

          _MenuTile(
            icon: Icons.directions_car_outlined,
            label: 'Meus veículos',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainNavigation(initialIndex: 4),
                ),
                (route) => false, // remove todas as rotas anteriores
              );
            },
          ),


          const Divider(height: 24),
          _MenuTile(
            icon: Icons.local_gas_station_outlined,
            label: 'Abastecimentos',
            onTap: () {
              Navigator.pop(context); // fecha o SideMenu
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FuelHistoryPage(),
              ),
            );
          },
        ),
          _MenuTile(
            icon: Icons.local_gas_station,
            label: 'Postos de Combustíveis',
            onTap: () {
              Navigator.pop(context); // fecha o menu lateral
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FuelStationsPage(),
                ),
              );
            },
          ),
          _MenuTile(
            icon: Icons.location_on_outlined,
            label: 'Locais',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpenseLocationsPage()),
              );
            },
          ),

          _MenuTile(
          icon: Icons.description_outlined,
          label: 'Despesas',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExpenseHistoryPage(),
              ),
            );
          },
        ),
          const Divider(height: 28),
          _MenuTile(
            icon: Icons.info_outline,
            label: 'Sobre',
            onTap: () {
              Navigator.pop(context); // fecha o sidemenu
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SobrePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          _Avatar(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Convidado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nenhum usuário autenticado',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              _Avatar(),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Carregando...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          final email = user.email ?? '';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _Avatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email.isNotEmpty ? email : 'Usuário',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sem dados de perfil',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final data = snapshot.data!.data()!;
        final name = (data['name'] ?? '') as String;
        final email = (data['email'] ?? user.email ?? '') as String;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _Avatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty
                        ? (email.isNotEmpty ? email : 'Usuário')
                        : name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 36,
      backgroundColor: Colors.amber,
      child: CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 32,
          backgroundColor: Colors.amber,
          child: Icon(Icons.person, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      color: enabled ? Colors.black87 : Colors.black38,
      fontWeight: FontWeight.w500,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: enabled ? Colors.black87 : Colors.black38),
      title: Text(label, style: textStyle),
      enabled: enabled,
      onTap: enabled ? onTap : null,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
