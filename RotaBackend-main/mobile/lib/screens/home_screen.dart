import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_scope.dart';
import '../models/ml_status.dart';
import '../models/stop_summary.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/language_flag_button.dart';
import 'map_screen.dart';
import 'smart_stop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _searchController = TextEditingController();
  late final ApiClient _api;
  late Future<List<StopSummary>> _stopsFuture;
  Future<MlStatus?>? _mlStatusFuture;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _stopsFuture = _api.fetchStopSummaries();
    _mlStatusFuture = _api.fetchMlStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _reloadStops() async {
    final f = _api.fetchStopSummaries();
    setState(() {
      _stopsFuture = f;
      _mlStatusFuture = _api.fetchMlStatus();
    });
    await f;
  }

  void _refreshMlStatus() {
    setState(() => _mlStatusFuture = _api.fetchMlStatus());
  }

  List<StopSummary> _applyFilter(List<StopSummary> all, String filter) {
    final q = filter.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (s) =>
              s.durakKodu.toLowerCase().contains(q) ||
              s.durakAdi.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openStop(StopSummary stop) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SmartStopScreen(durakKodu: stop.durakKodu),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppTheme.deepTransitBlue,
          ),
        ),
        actions: const [LanguageFlagButton(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        indicatorColor: AppTheme.deepTransitBlue,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              _navIndex == 0
                  ? Icons.directions_bus
                  : Icons.directions_bus_outlined,
              color: _navIndex == 0 ? Colors.white : null,
            ),
            label: l10n.navStops,
          ),
          NavigationDestination(
            icon: Icon(
              _navIndex == 1 ? Icons.map : Icons.map_outlined,
              color: _navIndex == 1 ? Colors.white : null,
            ),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: Icon(
              _navIndex == 2 ? Icons.psychology : Icons.psychology_outlined,
              color: _navIndex == 2 ? Colors.white : null,
            ),
            label: l10n.navAI,
          ),
          NavigationDestination(
            icon: Icon(
              _navIndex == 3 ? Icons.settings : Icons.settings_outlined,
              color: _navIndex == 3 ? Colors.white : null,
            ),
            label: l10n.navSettings,
          ),
        ],
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _StopsTab(
            stopsFuture: _stopsFuture,
            mlStatusFuture: _mlStatusFuture,
            searchController: _searchController,
            onReload: _reloadStops,
            onOpenStop: _openStop,
            applyFilter: _applyFilter,
          ),
          MapTab(stopsFuture: _stopsFuture),
          _MlDashboardTab(
            api: _api,
            mlStatusFuture: _mlStatusFuture,
            onRefresh: _refreshMlStatus,
          ),
          const _SettingsTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// TAB 1: DURAKLAR
// ──────────────────────────────────────────────────────────

class _StopsTab extends StatelessWidget {
  const _StopsTab({
    required this.stopsFuture,
    required this.mlStatusFuture,
    required this.searchController,
    required this.onReload,
    required this.onOpenStop,
    required this.applyFilter,
  });

  final Future<List<StopSummary>> stopsFuture;
  final Future<MlStatus?>? mlStatusFuture;
  final TextEditingController searchController;
  final Future<void> Function() onReload;
  final void Function(StopSummary) onOpenStop;
  final List<StopSummary> Function(List<StopSummary>, String) applyFilter;

  static IconData _iconForIndex(int i) {
    switch (i % 3) {
      case 0:
        return Icons.directions_bus;
      case 1:
        return Icons.sailing;
      default:
        return Icons.train;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: onReload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          // ── Headline ──
          Text(
            l10n.homeHeadline,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.deepTransitBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.homeSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // ── ML Status Chip ──
          if (mlStatusFuture != null)
            FutureBuilder<MlStatus?>(
              future: mlStatusFuture,
              builder: (context, snap) {
                final ml = snap.data;
                final live = ml?.isLiveMl ?? false;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: live
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: live
                          ? const Color(0xFF81C784)
                          : const Color(0xFFFFCC80),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: live
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF9800),
                          boxShadow: [
                            BoxShadow(
                              color: (live
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800))
                                  .withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.psychology_outlined,
                        size: 20,
                        color: live
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE65100),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          live ? l10n.mlStatusActive : l10n.mlStatusInactive,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: live
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      Text(
                        'XGBoost',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 16),

          // ── Search ──
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (_, val, __) => val.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => searchController.clear(),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Section header ──
          Text(
            l10n.stopsSection,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepTransitBlue,
            ),
          ),
          const SizedBox(height: 12),

          // ── Stop list ──
          FutureBuilder<List<StopSummary>>(
            future: stopsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.stopsLoadError,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: onReload,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              }
              final all = snapshot.data ?? [];
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  final filtered = applyFilter(all, value.text);
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        all.isEmpty ? l10n.noStopsOnServer : l10n.noSearchMatch,
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }
                  return Column(
                    children: filtered.asMap().entries.map((e) {
                      final i = e.key;
                      final stop = e.value;
                      final primary = stop.enYakinSeferDk != null
                          ? '${stop.enYakinSeferDk} ${l10n.minutesShort}'
                          : '—';
                      final secondary = stop.enYakinHatKodu ?? l10n.noTrip60;
                      final subtitle = stop.engelliErisimi
                          ? l10n.stopRampOk
                          : l10n.stopRampNo;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => onOpenStop(stop),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: i % 3 == 0
                                          ? const Color(0xFFDBEAFE)
                                          : i % 3 == 1
                                              ? const Color(0xFFE0E7FF)
                                              : const Color(0xFFFEF9C3),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _iconForIndex(i),
                                      color: i % 3 == 2
                                          ? const Color(0xFF854D0E)
                                          : AppTheme.deepTransitBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stop.durakAdi,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '$subtitle • ${stop.durakKodu}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        primary,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.deepTransitBlue,
                                        ),
                                      ),
                                      Text(
                                        secondary,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// TAB 2: YAPAY ZEKA PANELİ
// ──────────────────────────────────────────────────────────

class _MlDashboardTab extends StatelessWidget {
  const _MlDashboardTab({
    required this.api,
    required this.mlStatusFuture,
    required this.onRefresh,
  });

  final ApiClient api;
  final Future<MlStatus?>? mlStatusFuture;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // ── Title ──
        Text(
          l10n.mlDashTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepTransitBlue,
          ),
        ),
        const SizedBox(height: 20),

        // ── Live Status Card ──
        FutureBuilder<MlStatus?>(
          future: mlStatusFuture,
          builder: (context, snap) {
            final isLoading =
                snap.connectionState == ConnectionState.waiting;
            final ml = snap.data;
            final live = ml?.isLiveMl ?? false;
            final bridgeOk = ml?.bridgeOk ?? false;
            final modelsLoaded = ml?.modelsLoaded ?? false;

            return Column(
              children: [
                // Bridge + Model status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Big status indicator
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: live
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          border: Border.all(
                            color: live
                                ? const Color(0xFF66BB6A)
                                : const Color(0xFFFFB74D),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          live ? Icons.check_circle : Icons.error_outline,
                          size: 40,
                          color: live
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        live ? l10n.mlStatusActive : l10n.mlStatusInactive,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: live
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bridge row
                      _StatusRow(
                        icon: Icons.cable,
                        label: l10n.mlDashBridgeStatus,
                        value: bridgeOk
                            ? l10n.mlDashConnected
                            : l10n.mlDashDisconnected,
                        ok: bridgeOk,
                      ),
                      const SizedBox(height: 10),
                      // Model loaded row
                      _StatusRow(
                        icon: Icons.memory,
                        label: 'Model',
                        value: modelsLoaded
                            ? l10n.mlDashModelLoaded
                            : l10n.mlDashModelNotLoaded,
                        ok: modelsLoaded,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : onRefresh,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh, size: 18),
                          label: Text(
                            isLoading
                                ? l10n.mlDashCheckNow
                                : l10n.mlDashCheckNow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Model info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.model_training,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.mlDashModelName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.deepTransitBlue,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.mlDashModelDesc,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          l10n.mlDashFeatures,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepTransitBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pipeline card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mlDashPipeline,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepTransitBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PipelineStep(
                        number: 1,
                        label: l10n.mlDashStep1,
                        icon: Icons.phone_android,
                        color: const Color(0xFF1565C0),
                      ),
                      _PipelineArrow(),
                      _PipelineStep(
                        number: 2,
                        label: l10n.mlDashStep2,
                        icon: Icons.dns_outlined,
                        color: const Color(0xFF2E7D32),
                      ),
                      _PipelineArrow(),
                      _PipelineStep(
                        number: 3,
                        label: l10n.mlDashStep3,
                        icon: Icons.terminal,
                        color: const Color(0xFFE65100),
                      ),
                      _PipelineArrow(),
                      _PipelineStep(
                        number: 4,
                        label: l10n.mlDashStep4,
                        icon: Icons.psychology,
                        color: const Color(0xFF6A1B9A),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ok ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  const _PipelineStep({
    required this.number,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int number;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Center(
            child: Text(
              '$number',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PipelineArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: SizedBox(
        height: 20,
        child: Icon(
          Icons.arrow_downward,
          size: 14,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// TAB 3: AYARLAR
// ──────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeScope = LocaleScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text(
          l10n.settingsTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepTransitBlue,
          ),
        ),
        const SizedBox(height: 20),

        // Language
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.translate, color: AppTheme.deepTransitBlue),
                  const SizedBox(width: 10),
                  Text(
                    l10n.settingsLanguage,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepTransitBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.settingsLanguageDesc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LangButton(
                      label: l10n.settingsTurkish,
                      flag: '🇹🇷',
                      selected: localeScope.locale.languageCode == 'tr',
                      onTap: localeScope.locale.languageCode != 'tr'
                          ? localeScope.onToggleLanguage
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LangButton(
                      label: l10n.settingsEnglish,
                      flag: '🇬🇧',
                      selected: localeScope.locale.languageCode == 'en',
                      onTap: localeScope.locale.languageCode != 'en'
                          ? localeScope.onToggleLanguage
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // API Endpoint
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_outlined,
                      color: AppTheme.deepTransitBlue),
                  const SizedBox(width: 10),
                  Text(
                    l10n.settingsApiEndpoint,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepTransitBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SelectableText(
                  ApiClient.baseUrl,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppTheme.deepTransitBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // About
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.deepTransitBlue),
                  const SizedBox(width: 10),
                  Text(
                    l10n.settingsAbout,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepTransitBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.settingsAboutDesc,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    l10n.settingsVersion,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.label,
    required this.flag,
    required this.selected,
    this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.deepTransitBlue : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.deepTransitBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
