import 'package:flutter/material.dart';
import '../../game/collectibles/collectible.dart';
import '../../game/collectibles/collectible_manager.dart';
import '../../game/investigation/clue.dart';
import '../../game/investigation/investigation_lead.dart';
import '../../game/investigation/investigation_manager.dart';

/// Noir-style detective board dialog allowing players to examine discovered clues,
/// link evidence together to uncover story breakthroughs, and review collectibles.
class InvestigationBoardDialog extends StatefulWidget {
  final InvestigationManager investigationManager;
  final CollectibleManager collectibleManager;
  final VoidCallback onClose;

  const InvestigationBoardDialog({
    super.key,
    required this.investigationManager,
    required this.collectibleManager,
    required this.onClose,
  });

  @override
  State<InvestigationBoardDialog> createState() =>
      _InvestigationBoardDialogState();
}

class _InvestigationBoardDialogState extends State<InvestigationBoardDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected clue IDs for deduction linking
  final Set<String> _selectedClueIds = {};
  Clue? _inspectedClue;
  Collectible? _inspectedCollectible;
  InvestigationLead? _recentBreakthrough;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onToggleClueSelection(String clueId) {
    setState(() {
      if (_selectedClueIds.contains(clueId)) {
        _selectedClueIds.remove(clueId);
      } else {
        _selectedClueIds.add(clueId);
      }
      _feedbackMessage = null;
    });
  }

  void _attemptDeduction() {
    if (_selectedClueIds.length < 2) {
      setState(() {
        _feedbackMessage = 'Select at least 2 or 3 clues to form a deduction.';
      });
      return;
    }

    final lead = widget.investigationManager.connectClues(_selectedClueIds);
    setState(() {
      if (lead != null) {
        _recentBreakthrough = lead;
        _feedbackMessage = null;
        _selectedClueIds.clear();
      } else {
        _feedbackMessage =
            'No conclusive connection found. Examine clue dates, locations, and names.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 540),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0F14).withAlpha(250),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF2C3542), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(220),
                blurRadius: 30,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INVESTIGATION DOSSIER // EVIDENCE BOARD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LEADS SOLVED: ${widget.investigationManager.solvedLeadCount}/${widget.investigationManager.totalLeadCount}  •  '
                        'CLUES: ${widget.investigationManager.discoveredClueCount}/${widget.investigationManager.totalClueCount}  •  '
                        'COLLECTIBLES: ${widget.collectibleManager.collectedCount}/${widget.collectibleManager.totalCount}',
                        style: const TextStyle(
                          color: Color(0xFF7A8799),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2633),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(Icons.close, color: Colors.white70, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Navigation Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFD97736),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF708096),
                labelStyle: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
                tabs: const [
                  Tab(text: 'EVIDENCE / CLUES'),
                  Tab(text: 'DEDUCTIONS & LEADS'),
                  Tab(text: 'MEMORIES & COLLECTIBLES'),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Breakthrough Announcement Banner (if just solved)
              if (_recentBreakthrough != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1610),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFD97736), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFF9800), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '★ NEW BREAKTHROUGH UNLOCKED: ${_recentBreakthrough!.breakthroughTitle.toUpperCase()}',
                              style: const TextStyle(
                                color: Color(0xFFFFB74D),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _recentBreakthrough!.breakthroughDescription,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFFFF9800), size: 16),
                        onPressed: () {
                          setState(() {
                            _recentBreakthrough = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // 4. Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCluesTab(),
                    _buildLeadsTab(),
                    _buildCollectiblesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: CLUES & DEDUCTIONS ---
  Widget _buildCluesTab() {
    final discovered = widget.investigationManager.discoveredClues;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Discovered Clues List & Link Button
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(
                child: discovered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 32, color: Color(0xFF4C586A)),
                          const SizedBox(height: 8),
                          const Text(
                            'No evidentiary clues discovered yet.',
                            style: TextStyle(color: Color(0xFF708096), fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Explore Veyrapuram, examine documents, or inspect key items.',
                            style: TextStyle(
                              color: const Color(0xFF708096).withAlpha(160),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: discovered.length,
                      itemBuilder: (context, index) {
                        final clue = discovered[index];
                        final isSelected = _selectedClueIds.contains(clue.id);
                        final isInspected = _inspectedClue?.id == clue.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isInspected
                                ? const Color(0xFF222B38)
                                : const Color(0xFF131720),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD97736)
                                  : (isInspected
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF242C38)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            leading: GestureDetector(
                              onTap: () => _onToggleClueSelection(clue.id),
                              child: Icon(
                                isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: isSelected
                                    ? const Color(0xFFD97736)
                                    : const Color(0xFF6B7A8E),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              clue.title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFD1D8E0),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${clue.category.name.toUpperCase()} • ${clue.source}',
                              style: const TextStyle(
                                color: Color(0xFF708096),
                                fontSize: 9,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _inspectedClue = clue;
                              });
                              _onToggleClueSelection(clue.id);
                            },
                          ),
                        );
                      },
                    ),
              ),

              // Deduction Action Button
              if (_feedbackMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _feedbackMessage!,
                    style: const TextStyle(
                      color: Color(0xFFEF5350),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedClueIds.length >= 2
                        ? const Color(0xFFD97736)
                        : const Color(0xFF26303D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _attemptDeduction,
                  icon: const Icon(Icons.timeline_rounded, size: 15),
                  label: Text(
                    'CONNECT EVIDENCE // DEDUCE (${_selectedClueIds.length} SELECTED)',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        // Right Column: Clue Inspector Pane
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF11151E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF222B38)),
            ),
            child: _inspectedClue == null
                ? const Center(
                    child: Text(
                      'Select an evidentiary item to inspect case details and transcripts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF637082),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _inspectedClue!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SOURCE: ${_inspectedClue!.source.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFFD97736),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tags
                      Wrap(
                        spacing: 4,
                        children: _inspectedClue!.tags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A222F),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: const Color(0xFF2D3B4E)),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                color: Color(0xFF8BA2BE),
                                fontSize: 8.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _inspectedClue!.description,
                            style: const TextStyle(
                              color: Color(0xFFB1BAC7),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: LEADS & BREAKTHROUGHS ---
  Widget _buildLeadsTab() {
    final leads = widget.investigationManager.leads;

    return ListView.builder(
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        final discoveredClueCount = lead.requiredClueIds
            .where((id) => widget.investigationManager.isClueDiscovered(id))
            .length;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lead.isSolved
                ? const Color(0xFF1B221B)
                : const Color(0xFF131720),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: lead.isSolved
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF263140),
              width: lead.isSolved ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lead.title.toUpperCase(),
                      style: TextStyle(
                        color: lead.isSolved
                            ? const Color(0xFF81C784)
                            : Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: lead.isSolved
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF1E2835),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      lead.isSolved
                          ? 'SOLVED'
                          : '$discoveredClueCount / ${lead.requiredClueIds.length} CLUES DISCOVERED',
                      style: TextStyle(
                        color: lead.isSolved ? Colors.white : const Color(0xFF8BACCA),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                lead.hypothesis,
                style: const TextStyle(
                  color: Color(0xFFB0BAC8),
                  fontSize: 10.5,
                  height: 1.3,
                ),
              ),
              if (lead.isSolved) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1A12),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0xFF254B2A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '★ ${lead.breakthroughTitle}',
                        style: const TextStyle(
                          color: Color(0xFF81C784),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lead.breakthroughDescription,
                        style: const TextStyle(
                          color: Color(0xFFC8E6C9),
                          fontSize: 9.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: MEMORIES & COLLECTIBLES ---
  Widget _buildCollectiblesTab() {
    final list = widget.collectibleManager.collectibles;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Collectibles Grid
        Expanded(
          flex: 3,
          child: GridView.builder(
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final c = list[index];
              final isInspected = _inspectedCollectible?.id == c.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _inspectedCollectible = c;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isInspected
                        ? const Color(0xFF253142)
                        : (c.isCollected
                            ? const Color(0xFF131822)
                            : const Color(0xFF0D1016)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isInspected
                          ? const Color(0xFFD97736)
                          : (c.isCollected
                              ? const Color(0xFF2C394B)
                              : const Color(0xFF1C222C)),
                      width: isInspected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCollectibleIcon(c.type),
                        size: 22,
                        color: c.isCollected
                            ? const Color(0xFFD97736)
                            : const Color(0xFF4C586A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c.isCollected ? c.title : 'Undiscovered Memory',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.isCollected ? Colors.white : const Color(0xFF5A687A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.isCollected ? c.locationName : 'Location Unknown',
                              style: TextStyle(
                                color: c.isCollected
                                    ? const Color(0xFF7E8E9F)
                                    : const Color(0xFF424D5B),
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),

        // Right: Collectible Memory Inspector
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF11151E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF222B38)),
            ),
            child: _inspectedCollectible == null
                ? const Center(
                    child: Text(
                      'Select a collectible item to review Aadi\'s reflections and history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF637082),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _inspectedCollectible!.isCollected
                            ? _inspectedCollectible!.title
                            : 'UNDISCOVERED COLLECTIBLE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _inspectedCollectible!.isCollected
                            ? '${_inspectedCollectible!.type.name.toUpperCase()} • ${_inspectedCollectible!.locationName.toUpperCase()}'
                            : 'HIDDEN IN VEYRAPURAM',
                        style: const TextStyle(
                          color: Color(0xFFD97736),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _inspectedCollectible!.isCollected
                                    ? _inspectedCollectible!.description
                                    : 'Search coastal safehouses, family residences, harbour berths, and tea stalls to uncover this artifact.',
                                style: const TextStyle(
                                  color: Color(0xFFB1BAC7),
                                  fontSize: 10.5,
                                  height: 1.4,
                                ),
                              ),
                              if (_inspectedCollectible!.isCollected) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF19202C),
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: const Color(0xFF2C394D)),
                                  ),
                                  child: Text(
                                    _inspectedCollectible!.memoryText,
                                    style: const TextStyle(
                                      color: Color(0xFFD6DFEC),
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  IconData _getCollectibleIcon(CollectibleType type) {
    switch (type) {
      case CollectibleType.photograph:
        return Icons.photo_camera_back_outlined;
      case CollectibleType.hiddenLetter:
        return Icons.mail_outline_rounded;
      case CollectibleType.document:
        return Icons.description_outlined;
      case CollectibleType.memory:
        return Icons.psychology_outlined;
      case CollectibleType.storyClue:
        return Icons.fingerprint_rounded;
    }
  }
}
