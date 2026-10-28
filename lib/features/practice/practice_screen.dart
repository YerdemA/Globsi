import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/app/router.dart';
import 'package:globsi/core/data/country_repository.dart';
import 'package:globsi/core/geo/globe_geometry.dart';
import 'package:globsi/features/globe/globe_providers.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/engine/question_generator.dart';
import 'package:globsi/features/practice/engine/round_state.dart';
import 'package:globsi/features/practice/practice_setup_view.dart';
import 'package:globsi/features/practice/question_view.dart';
import 'package:globsi/features/practice/round_summary_view.dart';
import 'package:globsi/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Map or flag practice: filters → 10 questions → summary.
class PracticeScreen extends ConsumerStatefulWidget {
  const new({required this.mode, this.random, super.key});

  final PracticeMode mode;

  /// Randomness for question order and options; injectable for tests.
  final Random? random;

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late final Random _random = widget.random ?? Random();
  PracticeFilter _filter = const PracticeFilter();

  /// `null` while choosing filters.
  RoundState? _round;

  bool get _playing => _round != null && !_round!.isFinished;

  QuestionGenerator _generator(CountryCatalog catalog) => QuestionGenerator(
    countries: catalog.countries,
    filter: _filter,
    mode: widget.mode,
    random: _random,
  );

  void _start(CountryCatalog catalog) {
    final round = RoundState.start(_generator(catalog).generateRound());
    setState(() => _round = round);
    if (round.isShortened) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.practiceShortenedStarted(round.length))),
        );
    }
  }

  void _answer(String id) {
    final round = _round!;
    setState(
      () => _round = round.answer(
        round.current.options.firstWhere((o) => o.id == id),
      ),
    );
  }

  Future<void> _confirmQuit() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quitRoundTitle),
        content: Text(l10n.quitRoundBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.quitRoundConfirm),
          ),
        ],
      ),
    );
    if ((leave ?? false) && mounted) setState(() => _round = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(countryCatalogProvider);
    final geometry = widget.mode == PracticeMode.map
        ? ref.watch(globeGeometryProvider)
        : null;
    final title = widget.mode == PracticeMode.map
        ? l10n.menuMapPractice
        : l10n.menuFlagPractice;

    final Widget body;
    if (catalog.hasError || (geometry?.hasError ?? false)) {
      body = Center(
        child: FilledButton(
          onPressed: () => ref
            ..invalidate(countryCatalogProvider)
            ..invalidate(geoDatasetProvider),
          child: Text(l10n.retry),
        ),
      );
    } else if (catalog.value case final catalog?
        when geometry == null || geometry.hasValue) {
      body = _buildPhase(catalog, geometry?.value);
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return PopScope(
      canPop: !_playing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmQuit());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: body,
      ),
    );
  }

  Widget _buildPhase(CountryCatalog catalog, GlobeGeometry? geometry) {
    final round = _round;
    if (round == null) {
      return PracticeSetupView(
        filter: _filter,
        poolSize: _generator(catalog).pool.length,
        onChanged: (f) => setState(() => _filter = f),
        onStart: () => _start(catalog),
      );
    }
    if (round.isFinished) {
      return RoundSummaryView(
        state: round,
        onPlayAgain: () => _start(catalog),
        onChangeFilters: () => setState(() => _round = null),
        onMainMenu: () => context.go(Routes.home),
      );
    }
    return QuestionView(
      mode: widget.mode,
      state: round,
      geometry: geometry,
      onAnswer: _answer,
      onContinue: () => setState(() => _round = round.next()),
    );
  }
}
