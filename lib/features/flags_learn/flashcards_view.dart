import 'dart:math';

import 'package:flutter/material.dart';
import 'package:globsi/app/localized_names.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/ui/flag_image.dart';
import 'package:globsi/features/flags_learn/flashcard_deck.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Flashcards: a flag on the front, the country on the back. Tap to flip,
/// swipe (or use the bottom buttons) to move on.
class FlashcardsView extends StatefulWidget {
  const new({required this.countries, this.random, super.key});

  final List<Country> countries;

  /// Shuffle source; injectable for tests.
  final Random? random;

  @override
  State<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<FlashcardsView> {
  late final Random _random = widget.random ?? Random();
  final _pages = PageController();
  Continent? _continent;
  bool _shuffled = false;
  int _shuffleSeed = 0;
  int _page = 0;
  List<Country>? _deck;
  String? _deckLanguage;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<Country> _buildDeck(String language) => flashcardDeck(
    widget.countries,
    language,
    continent: _continent,
    random: _shuffled ? Random(_shuffleSeed) : null,
  );

  void _reset({required bool shuffled, Continent? continent}) {
    setState(() {
      _continent = continent;
      _shuffled = shuffled;
      if (shuffled) _shuffleSeed = _random.nextInt(1 << 31);
      _deck = null;
      _page = 0;
    });
    if (_pages.hasClients) _pages.jumpToPage(0);
  }

  void _goTo(int page) => _pages.animateToPage(
    page,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    if (_deck == null || _deckLanguage != language) {
      _deck = _buildDeck(language);
      _deckLanguage = language;
    }
    final deck = _deck!;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.filterAll),
                selected: _continent == null,
                onSelected: (_) => _reset(shuffled: _shuffled),
              ),
              for (final continent in continentOrder)
                ChoiceChip(
                  label: Text(continent.label(l10n)),
                  selected: _continent == continent,
                  onSelected: (_) =>
                      _reset(continent: continent, shuffled: _shuffled),
                ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            // A new deck starts fresh flipped states.
            key: ValueKey((_continent, _shuffleSeed, _shuffled, language)),
            controller: _pages,
            itemCount: deck.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FlipCard(country: deck[i]),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                IconButton.filledTonal(
                  iconSize: 28,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.previous,
                  onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
                ),
                Expanded(
                  child: Text(
                    l10n.cardPosition(_page + 1, deck.length),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  iconSize: 28,
                  isSelected: _shuffled,
                  icon: const Icon(Icons.shuffle),
                  tooltip: l10n.shuffle,
                  onPressed: () =>
                      _reset(continent: _continent, shuffled: true),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  iconSize: 28,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.next,
                  onPressed: _page < deck.length - 1
                      ? () => _goTo(_page + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A card that turns over on tap.
class FlipCard extends StatefulWidget {
  const new({required this.country, super.key});

  final Country country;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_flip.status
        case AnimationStatus.completed || AnimationStatus.forward) {
      _flip.reverse();
    } else {
      _flip.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final country = widget.country;

    final front = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24,
      children: [
        FlagImage(
          country: country,
          width: 260,
          height: 195,
          semanticsLabel: l10n.tapToReveal,
        ),
        Text(
          l10n.tapToReveal,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final back = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        FlagImage(country: country, width: 96, height: 72),
        Text(
          country.name.resolve(language),
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          '${l10n.infoCapital}: ${country.capital.resolve(language)}',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          country.continent.label(l10n),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final angle = Curves.easeInOut.transform(_flip.value) * pi;
          final showBack = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Card(
              elevation: 2,
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(pi),
                          child: back,
                        )
                      : front,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
