import 'package:fashion_studio/screens/clients_screen.dart';
import 'package:fashion_studio/screens/commandes_screen.dart';
import 'package:fashion_studio/screens/dashboard_screen.dart';
import 'package:fashion_studio/screens/designs_screen.dart';
import 'package:fashion_studio/screens/paiements_screen.dart';
import 'package:fashion_studio/services/api_client.dart';
import 'package:fashion_studio/services/auth_service.dart';
import 'package:fashion_studio/services/clients_service.dart';
import 'package:fashion_studio/services/commandes_service.dart';
import 'package:fashion_studio/services/data_service.dart';
import 'package:fashion_studio/services/designs_service.dart';
import 'package:fashion_studio/services/paiements_service.dart';
import 'package:flutter/material.dart';

enum AppSection {
  dashboard,
  clients,
  designs,
  commandes,
  paiements,
}

class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    required this.apiClient,
    required this.authService,
    required this.dataService,
    this.initialSection = AppSection.dashboard,
  });

  final ApiClient apiClient;
  final AuthService authService;
  final DataService dataService;
  final AppSection initialSection;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  late AppSection _section;
  late final ClientsService _clientsService;
  late final DesignsService _designsService;
  late final CommandesService _commandesService;
  late final PaiementsService _paiementsService;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _clientsService = ClientsService(apiClient: widget.apiClient);
    _designsService = DesignsService(apiClient: widget.apiClient);
    _commandesService = CommandesService(apiClient: widget.apiClient);
    _paiementsService = PaiementsService(apiClient: widget.apiClient);
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final title = switch (_section) {
      AppSection.dashboard => 'Tableau de bord',
      AppSection.clients => 'Clients',
      AppSection.designs => 'Designs',
      AppSection.commandes => 'Commandes',
      AppSection.paiements => 'Paiements',
    };

    final body = switch (_section) {
      AppSection.dashboard => DashboardScreen(dataService: widget.dataService),
      AppSection.clients => ClientsScreen(clientsService: _clientsService),
      AppSection.designs => DesignsScreen(designsService: _designsService),
      AppSection.commandes => CommandesScreen(
          commandesService: _commandesService,
          clientsService: _clientsService,
          designsService: _designsService,
        ),
      AppSection.paiements => PaiementsScreen(
          paiementsService: _paiementsService,
          commandesService: _commandesService,
          clientsService: _clientsService,
          designsService: _designsService,
        ),
    };

    final nav = _NavItems(
      section: _section,
      onSelect: (s) {
        setState(() {
          _section = s;
        });
        if (!isDesktop) {
          Navigator.of(context).pop();
        }
      },
      onLogout: _logout,
    );

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withOpacity(0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'FS',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: nav,
          ),
        ),
        body: body,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                right: BorderSide(
                    color: const Color(0xFFDC2626).withOpacity(0.10)),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFFDC2626).withOpacity(0.25),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'FS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fashion Studio',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                              SizedBox(height: 2),
                              Text('Atelier',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF737373))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: nav),
                ],
              ),
            ),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: const Color(0xFFFAFAFA),
              appBar: AppBar(
                title: Text(title),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItems extends StatelessWidget {
  const _NavItems({
    required this.section,
    required this.onSelect,
    required this.onLogout,
  });

  final AppSection section;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NavButton(
          active: section == AppSection.dashboard,
          icon: Icons.dashboard_outlined,
          label: 'Tableau de bord',
          onTap: () => onSelect(AppSection.dashboard),
        ),
        _NavButton(
          active: section == AppSection.clients,
          icon: Icons.group_outlined,
          label: 'Clients',
          onTap: () => onSelect(AppSection.clients),
        ),
        _NavButton(
          active: section == AppSection.designs,
          icon: Icons.palette_outlined,
          label: 'Designs',
          onTap: () => onSelect(AppSection.designs),
        ),
        _NavButton(
          active: section == AppSection.commandes,
          icon: Icons.shopping_bag_outlined,
          label: 'Commandes',
          onTap: () => onSelect(AppSection.commandes),
        ),
        _NavButton(
          active: section == AppSection.paiements,
          icon: Icons.credit_card,
          label: 'Paiements',
          onTap: () => onSelect(AppSection.paiements),
        ),
        const SizedBox(height: 16),
        const Divider(),
        _NavButton(
          active: false,
          icon: Icons.logout,
          label: 'Déconnexion',
          danger: true,
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)])
        : null;

    final fg = active
        ? Colors.white
        : danger
            ? const Color(0xFFDC2626)
            : const Color(0xFF374151);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: bg,
        color: active
            ? null
            : (danger ? const Color(0xFFFFF1F2) : const Color(0x00FFFFFF)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w700, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
