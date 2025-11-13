import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edhrec_commander_tinder/controllers/deck_controller.dart';
import '../models/all_commanders.dart';
import 'draft_screen.dart';

class CommanderSelectScreen extends StatefulWidget {
  final List<PotentialCommander> commanders;
  const CommanderSelectScreen({super.key, required this.commanders});

  @override
  State<CommanderSelectScreen> createState() => _CommanderSelectScreenState();
}

class _CommanderSelectScreenState extends State<CommanderSelectScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _fieldFocus = FocusNode();
  PotentialCommander? _selected;
  String? _error;

  @override
  void dispose() {
    _fieldFocus.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckController>();
    final all = widget.commanders;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _SurfacePanel(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Commander Tinder',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Search a commander to start drafting recommendations.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      RawAutocomplete<PotentialCommander>(
                        focusNode: _fieldFocus,
                        textEditingController: _nameController,
                        displayStringForOption: (o) => o.name,
                        optionsBuilder: (TextEditingValue value) {
                          final query = value.text.trim().toLowerCase();
                          if (query.isEmpty) return all.take(20);
                          return all
                              .where(
                                (c) => c.name.toLowerCase().contains(query),
                              )
                              .take(25);
                        },
                        onSelected: (c) => setState(() {
                          _selected = c;
                          _nameController.text = c.name;
                          _nameController.selection = TextSelection.collapsed(
                            offset: c.name.length,
                          );
                        }),
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText:
                                      'Commander Name (${all.length} loaded)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _selected != null
                                      ? IconButton(
                                          tooltip: 'Clear selection',
                                          icon: const Icon(Icons.clear),
                                          onPressed: () => setState(() {
                                            _selected = null;
                                            _nameController.clear();
                                          }),
                                        )
                                      : null,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => onFieldSubmitted(),
                              );
                            },
                        optionsViewBuilder: (context, onSel, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 380,
                                  minWidth: 480,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final opt = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSel(opt),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 42,
                                              height: 42,
                                              child:
                                                  (opt.picture != null &&
                                                      opt.picture!.isNotEmpty)
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        opt.picture!,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFE1E8EF,
                                                          ),
                                                      child: Text(
                                                        opt.name.isNotEmpty
                                                            ? opt.name[0]
                                                            : '?',
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                opt.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: deck.loadingCommander
                            ? const Center(child: CircularProgressIndicator())
                            : FloatingActionButton(
                                onPressed: () async {
                                  if (_selected == null) {
                                    setState(
                                      () => _error = 'Please pick a commander',
                                    );
                                    return;
                                  }
                                  setState(() => _error = null);
                                  deck.setCommanderUrl(_selected!.url);
                                  await deck.loadCommander();
                                  if (deck.loadError != null) {
                                    if (!mounted) return;
                                    setState(
                                      () => _error = 'Failed to load commander',
                                    );
                                    return;
                                  }
                                  if (!mounted) return;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const DraftScreen(),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.play_arrow),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SurfacePanel extends StatelessWidget {
  final Widget child;
  const _SurfacePanel({required this.child});
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: child,
    );
  }
}
