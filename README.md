# 🚗 DriveUP — Gerenciador de Veículos e Gastos

Aplicativo mobile desenvolvido em **Flutter** para gerenciamento de veículos, abastecimentos, despesas, resumo mensal e lembretes automotivos.  
Inclui dashboards interativos, histórico detalhado, área de perfil e integração completa com Firebase.

---

## ✨ Funcionalidades

### 🔹 Gestão de Veículos
- Cadastro/edição de veículos  
- Histórico unificado (abastecimento + despesas)  
- Visualização individual por veículo  

### 🔹 Abastecimentos
- Registro com cálculo automático  
- Associação ao veículo  
- Histórico completo  
- Edição e remoção  

### 🔹 Despesas
- Registro com valor, local, data, odômetro e tipo  
- Associação ao veículo  
- Histórico detalhado  
- Edição e exclusão  

### 🔹 Lembretes & Notificações
- Sistema de lembretes baseado em data e hora  
- Notificações locais via **flutter_local_notifications**  
- Apenas notifica quando realmente chegar o horário configurado  
- Lembretes armazenados no Firestore  

### 🔹 Perfil do Usuário
- Edição de nome, e-mail e dados da CNH  
- Logout e exclusão de conta  
- Integração com Firebase Auth  

### 🔹 Resumo Mensal
- Gráfico donut com resumo de abastecimentos e despesas  
- Navegação entre meses  
- Cálculo automático via Firestore  

---

## 🧱 Tecnologias Utilizadas

| Tecnologia | Função |
|-----------|--------|
| **Flutter 3.35+** | UI e navegação |
| **Dart** | Lógica de negócio |
| **Firebase Auth** | Autenticação de usuários |
| **Cloud Firestore** | Banco de dados |
| **Flutter Local Notifications** | Alertas e lembretes |
| **Timezone package** | Agendamentos precisos |
| **Material 3** | Design moderno |

---

## 📂 Arquitetura do Projeto

lib/
├─ navigation/
│   └─ main_navigation.dart
├─ screens/
│   ├─ home_page.dart
│   ├─ abastecimento_page.dart
│   ├─ despesa_page.dart
│   ├─ veiculos_page.dart
│   ├─ notificacoes_page.dart
│   ├─ empty_notifications_page.dart
│   ├─ perfil_page.dart
│   ├─ vehicle_history_page.dart
│   └─ sidemenu_page.dart
├─ services/
│   ├─ vehicle_service.dart
│   ├─ expense_service.dart
│   ├─ fuel_service.dart
│   ├─ summary_service.dart
│   ├─ reminder_service.dart
│   └─ notification_service.dart
├─ widgets/
│   ├─ profile_avatar_button.dart
│   └─ custom_inputs.dart
└─ main.dart

## 🔧 Como Rodar o Projeto

    1. Instale as dependências

        flutter pub get

    2. Configure o Firebase

        Baixe:

            google-services.json (Android)

            GoogleService-Info.plist (iOS)

        Ative no Firebase Console:

            Authentication

            Cloud Firestore

    3. Execute o app
flutter run

## 🔒 Segurança e Boas Práticas

As coleções seguem a estrutura:

users/{uid}/vehicles
users/{uid}/expenses
users/{uid}/fuels
users/{uid}/reminders


