import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../l10n/ml_messages.dart';
import '../models/approaching_bus.dart';
import '../models/ml_status.dart';
import '../models/stop_meta.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/comfort_card.dart';
import '../widgets/language_flag_button.dart';

class _StopPageData {
  const _StopPageData({
    required this.buses,
    this.mlStatus,
    this.stopMeta,
  });

  final List<ApproachingBus> buses;
  final MlStatus? mlStatus;
  final StopMeta? stopMeta;
}

class SmartStopScreen extends StatefulWidget {
  const SmartStopScreen({super.key, required this.durakKodu});

  final String durakKodu;

  @override
  State<SmartStopScreen> createState() => _SmartStopScreenState();
}

class _SmartStopScreenState extends State<SmartStopScreen> {
  late final ApiClient _api;
  late Future<_StopPageData> _future;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _future = _load();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<_StopPageData> _load() async {
    final results = await Future.wait<Object?>([
      _api.fetchApproachingBuses(widget.durakKodu),
      _api.fetchMlStatus(),
      _api.fetchStopMeta(widget.durakKodu),
    ]);
    return _StopPageData(
      buses: results[0]! as List<ApproachingBus>,
      mlStatus: results[1] as MlStatus?,
      stopMeta: results[2] as StopMeta?,
    );
  }

  Future<void> _onRefresh() async {
    final f = _load();
    _future = f;
    setState(() {});
    await f;
  }

  void _showMlInfo(MlStatus? status) {
    final l10n = AppLocalizations.of(context)!;
    final buf = StringBuffer()
      ..writeln(l10n.mlDialogIntro)
      ..writeln()
      ..writeln(l10n.mlDialogFlow)
      ..writeln()
      ..writeln(l10n.mlDialogCapacity);

    if (status != null) {
      buf
        ..writeln()
        ..writeln(
          status.mlEnabled ? l10n.mlServerOn : l10n.mlServerOff,
        );
      final line = localizedMlDetailLine(status, l10n);
      if (line != null) buf.writeln(line);
    } else {
      buf
        ..writeln()
        ..writeln(l10n.mlStatusUnreadable);
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mlDialogTitle),
        content: SingleChildScrollView(child: Text(buf.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<_StopPageData>(
      future: _future,
      builder: (context, snapshot) {
        final pageTitle = snapshot.hasData
            ? (snapshot.data!.stopMeta?.durakAdi ?? widget.durakKodu)
            : widget.durakKodu;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(pageTitle),
            actions: [
              const LanguageFlagButton(),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: l10n.mlTooltipAbout,
                onPressed: () async {
                  final s = await _api.fetchMlStatus();
                  if (!context.mounted) return;
                  _showMlInfo(s);
                },
              ),
            ],
          ),
          body: _buildBody(context, snapshot, l10n),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_StopPageData> snapshot,
    AppLocalizations l10n,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.busesLoadError}\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _onRefresh,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final data = snapshot.data!;
    final buses = data.buses;
    final ml = data.mlStatus;

    if (buses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.noApproaching60,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (ml != null)
                    _MlInsightBanner(
                      message: localizedMlBanner(ml, l10n),
                      live: ml.isLiveMl,
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _onRefresh,
                    child: Text(l10n.refresh),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: buses.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SmartTerminalHero(l10n: l10n),
                  if (ml != null) ...[
                    const SizedBox(height: 12),
                    _MlInsightBanner(
                      message: localizedMlBanner(ml, l10n),
                      live: ml.isLiveMl,
                    ),
                  ],
                ],
              ),
            );
          }
          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.pullRefreshHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            );
          }
          final bus = buses[index - 2];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ComfortCard(bus: bus),
          );
        },
      ),
    );
  }
}

class _MlInsightBanner extends StatelessWidget {
  const _MlInsightBanner({
    required this.message,
    required this.live,
  });

  final String message;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final bg = live
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF8E1);
    final fg = live
        ? const Color(0xFF1B5E20)
        : const Color(0xFFE65100);
    final icon = live ? Icons.psychology_outlined : Icons.engineering_outlined;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartTerminalHero extends StatelessWidget {
  const _SmartTerminalHero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF001E40), Color(0xFF003366)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.liveStatus,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.smartStopTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.psychology_outlined,
            color: Colors.white.withValues(alpha: 0.5),
            size: 28,
          ),
        ],
      ),
    );
  }
}
