import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/approaching_bus.dart';
import '../theme/app_theme.dart';

class ComfortCard extends StatelessWidget {
  const ComfortCard({super.key, required this.bus});

  final ApproachingBus bus;

  static Color crowdingColor(int dolulukOrani) {
    if (dolulukOrani < 50) return const Color(0xFF059669);
    if (dolulukOrani <= 80) return const Color(0xFFC2410C);
    return const Color(0xFFBA1A1A);
  }

  static void _showMlDetailDialog(
    BuildContext context,
    ApproachingBus bus,
    AppLocalizations l10n,
  ) {
    final crowd = crowdingColor(bus.dolulukOrani);
    final source = bus.mlTahmin
        ? l10n.mlDetailSourceModel
        : l10n.mlDetailSourceFallback;
    final accessStatus = bus.engelliErisimi
        ? l10n.mlDetailAccessibleYes
        : l10n.mlDetailAccessibleNo;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.mlDetailDialogTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.deepTransitBlue,
              ),
            ),
            const Divider(height: 24),
            Text(
              l10n.mlDetailRoute(bus.hatKodu, bus.hatAdi),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.mlDetailArrival(bus.kalanSureDk),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.mlDetailCrowding(bus.dolulukOrani),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: crowd,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: bus.dolulukOrani.clamp(0, 100) / 100.0,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE8E8E8),
                      valueColor: AlwaysStoppedAnimation<Color>(crowd),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.comfortPaxEstimate(bus.beklenenYolcu, bus.aracKapasitesi),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: bus.mlTahmin
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: bus.mlTahmin
                      ? const Color(0xFF90CAF9)
                      : const Color(0xFFFFCC80),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  l10n.mlDetailSource(source),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: bus.mlTahmin
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  bus.engelliErisimi ? Icons.accessible : Icons.not_accessible,
                  size: 20,
                  color: bus.engelliErisimi
                      ? Colors.blue.shade700
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.mlDetailAccessible(accessStatus),
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final crowd = crowdingColor(bus.dolulukOrani);
    final label = l10n.comfortFullnessPercent(bus.dolulukOrani);

    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _showMlDetailDialog(context, bus, l10n),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.brightWarningYellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            bus.hatKodu,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF221B00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.comfortRoute,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bus.hatAdi,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  height: 1.25,
                                  color: AppTheme.deepTransitBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bus.engelliErisimi)
                    Icon(Icons.accessible, color: Colors.blue.shade700, size: 26),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: bus.mlTahmin
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: bus.mlTahmin
                            ? const Color(0xFF90CAF9)
                            : const Color(0xFFFFCC80),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        bus.mlTahmin
                            ? l10n.comfortMlModelBadge
                            : l10n.comfortMlFallbackBadge,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: bus.mlTahmin
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    l10n.comfortPaxEstimate(
                      bus.beklenenYolcu,
                      bus.aracKapasitesi,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${bus.kalanSureDk}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: AppTheme.deepTransitBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.comfortMinutesAway,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepTransitBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.comfortMlLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: crowd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (bus.dolulukOrani.clamp(0, 100)) / 100.0,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8E8E8),
                  valueColor: AlwaysStoppedAnimation<Color>(crowd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
