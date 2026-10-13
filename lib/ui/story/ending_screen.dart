import 'package:flutter/material.dart';
import '../../game/story/ending_manager.dart';
import '../../game/story/story_choice_system.dart';

/// Cinematic noir ending screen displaying epilogue slides, character fates,
/// decision impact review, and credit roll.
class EndingScreen extends StatefulWidget {
  final EndingManager endingManager;
  final StoryChoiceSystem choiceSystem;
  final VoidCallback onReturnToFreeRoam;

  const EndingScreen({
    super.key,
    required this.endingManager,
    required this.choiceSystem,
    required this.onReturnToFreeRoam,
  });

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  bool _showingFates = false;

  Color get _accentColor {
    final type = widget.endingManager.activeEnding?.type;
    switch (type) {
      case EndingType.walkAway:
        return const Color(0xFF10B981); // Emerald green for hope / Vayal
      case EndingType.revenge:
        return const Color(0xFFEF4444); // Crimson red for violence / Revenge
      case EndingType.exposeEverything:
        return const Color(0xFF38BDF8); // Steel ice blue for justice / Expose
      case null:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.endingManager.activeEnding;
    if (data == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: widget.endingManager,
        builder: (context, _) {
          return Container(
            color: Colors.black.withValues(alpha: 0.94),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: widget.endingManager.isCreditsRolling
                    ? _buildCreditsView(data)
                    : _showingFates
                        ? _buildFatesView(data)
                        : _buildEpilogueView(data),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpilogueView(EndingResolutionData data) {
    final slideIndex = widget.endingManager.currentSlideIndex;
    final totalSlides = data.epilogueSlides.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.code,
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            // Slide indicator pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'ACT V EPILOGUE • ${slideIndex + 1} / $totalSlides',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24.0),

        // Thematic Quote box
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            data.thematicQuote,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13.0,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 24.0),

        // Prose slide content
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  data.epilogueSlides[slideIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    height: 1.8,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20.0),

        // Navigation Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (slideIndex > 0)
              OutlinedButton.icon(
                onPressed: () => widget.endingManager.previousSlide(),
                icon: const Icon(Icons.arrow_back, size: 16.0, color: Colors.white70),
                label: const Text('PREVIOUS', style: TextStyle(color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                ),
              )
            else
              const SizedBox.shrink(),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showingFates = true;
                    });
                  },
                  child: const Text(
                    'CHARACTER FATES',
                    style: TextStyle(color: Colors.white60, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton.icon(
                  onPressed: () {
                    final hasMore = widget.endingManager.advanceSlide();
                    if (!hasMore) {
                      setState(() {
                        _showingFates = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16.0),
                  label: Text(
                    slideIndex < totalSlides - 1 ? 'NEXT' : 'CONTINUE',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFatesView(EndingResolutionData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FATES & CONSEQUENCES',
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'Veyrapuram Character Dossier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showingFates = false;
                });
              },
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // Alignment scores recap
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatPill('FAMILY LOYALTY', '${widget.choiceSystem.familyLoyalty}%', const Color(0xFF10B981)),
              _buildStatPill('CRIMINAL REP', '${widget.choiceSystem.criminalReputation}%', const Color(0xFFEF4444)),
              _buildStatPill('POLICE TRUST', '${widget.choiceSystem.policeTrust}%', const Color(0xFF38BDF8)),
            ],
          ),
        ),

        const SizedBox(height: 16.0),

        // Character fate cards
        Expanded(
          child: ListView.separated(
            itemCount: data.charactersFate.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final character = data.charactersFate.keys.elementAt(index);
              final fate = data.charactersFate[character]!;

              return Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.0,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        character.toUpperCase(),
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        fate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13.0,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showingFates = false;
                });
              },
              icon: const Icon(Icons.arrow_back, size: 16.0, color: Colors.white70),
              label: const Text('BACK TO STORY', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton.icon(
              onPressed: () => widget.endingManager.startCredits(),
              icon: const Icon(Icons.movie_outlined, size: 16.0),
              label: const Text(
                'ROLL CREDITS',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditsView(EndingResolutionData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'V A Y A L',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 8.0,
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Center(
          child: Text(
            '“Can a man escape the person he used to be?”',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        const SizedBox(height: 24.0),

        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _creditRole('PROTAGONIST', 'Aadithyan "Aadi" Menon'),
                  const SizedBox(height: 16.0),
                  _creditRole('FAMILY', 'Meera Menon • Diya Menon'),
                  const SizedBox(height: 16.0),
                  _creditRole('THE POLICE', 'Inspector Raghav (Crime Branch)'),
                  const SizedBox(height: 16.0),
                  _creditRole('THE UNDERWORLD', 'Devraj • Rahu • Manu • Imran'),
                  const SizedBox(height: 16.0),
                  _creditRole('SETTING', 'Veyrapuram Open World (Forest, Village, Old Town, Harbor)'),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: _accentColor.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'CONCLUDED WITH: ${data.code} — ${data.title}',
                      style: TextStyle(
                        color: _accentColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20.0),

        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              widget.endingManager.concludeEnding();
              widget.onReturnToFreeRoam();
            },
            icon: const Icon(Icons.explore, size: 18.0),
            label: const Text(
              'CONTINUE IN OPEN WORLD (FREE ROAM)',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _creditRole(String role, String names) {
    return Column(
      children: [
        Text(
          role,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11.0,
            letterSpacing: 2.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          names,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatPill(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10.0,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
