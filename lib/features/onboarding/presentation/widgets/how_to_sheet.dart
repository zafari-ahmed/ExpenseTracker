import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_shell.dart';
import '../../../../core/services/service_providers.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';

const howToSlideAssets = <String>[
  'assets/howto/howto_01_add_card.jpg',
  'assets/howto/howto_02_sender.jpg',
  'assets/howto/howto_03_parse_sms.jpg',
  'assets/howto/howto_04_parse_notification.jpg',
  'assets/howto/howto_05_sync.jpg',
];

Future<void> showHowToSheet(
  BuildContext context,
  WidgetRef ref, {
  bool markSeen = true,
}) async {
  await runWithHiddenAddFab(
    ref,
    () => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: height,
              child: const EtSurfaceCard(
                radius: AppRadii.large,
                padding: EdgeInsets.zero,
                child: HowToSheet(),
              ),
            ),
          ),
        );
      },
    ),
  );
  if (markSeen) {
    await ref.read(onboardingServiceProvider).markHowToSeen();
  }
}

class HowToSheet extends StatefulWidget {
  const HowToSheet({super.key});

  @override
  State<HowToSheet> createState() => _HowToSheetState();
}

class _HowToSheetState extends State<HowToSheet> {
  final _pages = PageController();
  int _index = 0;

  bool get _isLast => _index >= howToSlideAssets.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    await _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      'How to use',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_isLast)
                    const SizedBox(width: 48)
                  else
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.archivo(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: howToSlideAssets.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        howToSlideAssets[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < howToSlideAssets.length; i++)
                  Container(
                    width: i == _index ? 18 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0
                          ? null
                          : () => _goTo(_index - 1),
                      child: const Text('Prev'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_isLast) {
                          Navigator.pop(context);
                        } else {
                          _goTo(_index + 1);
                        }
                      },
                      child: Text(_isLast ? 'Done' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
