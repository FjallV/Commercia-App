import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:commercia/data/models/event_viewmodel.dart';
import 'package:commercia/data/repositories/event_repository.dart';
import 'package:commercia/presentation/styles/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:commercia/presentation/widgets/app_bar_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventScreen extends StatefulWidget {
  @override
  State<EventScreen> createState() => _EventScreenState();
  final ValueNotifier<bool>? isSearchMode;
  const EventScreen({super.key, this.isSearchMode});
}

class _EventScreenState extends State<EventScreen> {
  final EventViewModel viewModel =
      EventViewModel(eventRepository: EventRepository());
  late Future<List<EventModel>> _events;
  final searchText = ValueNotifier<String>('');
  late final ValueNotifier<bool> _isSearchMode;
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = true;
  int _selectedClubFilter = 0; // 0 = Alle, 1 = Altherrenverband, 2 = Aktivitas

  @override
  void initState() {
    super.initState();
    _isSearchMode = widget.isSearchMode ?? ValueNotifier(false);
    _isSearchMode.addListener(() {
      if (!_isSearchMode.value) {
        searchText.value = '';
      }
    });
    _scrollController.addListener(_onScroll);
    _events = getData();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showFilters) {
      setState(() => _showFilters = false);
    } else if (direction == ScrollDirection.forward && !_showFilters) {
      setState(() => _showFilters = true);
    }
  }

  @override
  void dispose() {
    if (widget.isSearchMode == null) {
      _isSearchMode.dispose();
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<EventModel>> getData() async {
    try {
      _events = viewModel.load();
    } catch (Exc) {
      print(Exc);
      setState(() {});
      rethrow;
    }

    setState(() {});
    return _events;
  }

  Future<void> _onRefresh() async {
    final newEvents = viewModel.load();
    setState(() {
      _events = newEvents;
    });
    await newEvents;
  }

  bool _matchesClubFilter(EventModel event) {
    switch (_selectedClubFilter) {
      case 1: // Altherrenverband: club 0 or 1
        return event.club == 0 || event.club == 1;
      case 2: // Aktivitas: club 0 or 2
        return event.club == 0 || event.club == 2;
      default: // Alle
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarEvents(context, searchText, _isSearchMode),
      body: Column(
        children: [
          // Filter Chips
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showFilters
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          _ClubFilterChip(
                            label: 'Alle',
                            selected: _selectedClubFilter == 0,
                            onSelected: (_) =>
                                setState(() => _selectedClubFilter = 0),
                          ),
                          const SizedBox(width: 8),
                          _ClubFilterChip(
                            label: 'Altherrenverband',
                            selected: _selectedClubFilter == 1,
                            onSelected: (_) =>
                                setState(() => _selectedClubFilter = 1),
                          ),
                          const SizedBox(width: 8),
                          _ClubFilterChip(
                            label: 'Aktivitas',
                            selected: _selectedClubFilter == 2,
                            onSelected: (_) =>
                                setState(() => _selectedClubFilter = 2),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
          // Event List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: searchText,
              builder: (context, value, child) => FutureBuilder(
                future: _events,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${snapshot.error} occurred',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: Theme.of(context).colorScheme.primary,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: snapshot.data!
                                  .where((event) =>
                                      event.title.toLowerCase().contains(
                                          searchText.value.toLowerCase()) &&
                                      _matchesClubFilter(event))
                                  .map((event) => EventCard(event: event))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _ClubFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      shape: StadiumBorder(),
      selectedColor: Theme.of(context).colorScheme.primary,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    // event.image kann ein voller Pfad sein (z.B. 'assets/images/event/aarau.png')
    // oder nur ein Name. Wir extrahieren den Dateinamen ohne Endung und hängen .png an.
    final rawName = event.image!.split('/').last;
    final baseName = rawName.contains('.')
        ? rawName.substring(0, rawName.lastIndexOf('.'))
        : rawName;
    final imageUrl = Supabase.instance.client.storage
        .from('event-photos')
        .getPublicUrl('$baseName.png');
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            surfaceTintColor: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            elevation: 1,
            child: InkWell(
              onTap: () {
                context.pushNamed('event_details', extra: event);
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Hero(
                            tag: event.id,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 25,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Text(event.date_short!,
                                        style: ChipTextStyle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: TitleTextStyle),
                          SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(event.card_text!, style: BodyTextStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(bottom: 10, left: 12, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (event.location != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      event.location!,
                                      style: BodyTextStyle.copyWith(
                                          fontSize:
                                              (BodyTextStyle.fontSize ?? 14) -
                                                  2),
                                    ),
                                  ],
                                )
                              else
                                SizedBox.shrink(),
                              if (event.signup_url != null)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    launchUrl(Uri.parse(event.signup_url!));
                                  },
                                  label: Text('Anmelden'),
                                  icon: Icon(Icons.check),
                                ),
                            ])),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

//TODO:
// - Cancel search on back
// - Dont show search when switchting screens
AppBarWithSearchSwitch appBarEvents(BuildContext context,
    ValueNotifier<String> searchText, ValueNotifier<bool> isSearchMode) {
  return AppBarWithSearchSwitch(
    customIsSearchModeNotifier: isSearchMode,
    customTextNotifier: searchText,
    //onChanged: (text) => searchText.value = text,
    clearOnClose: true,
    fieldHintText: 'Suchen',
    appBarBuilder: (context) {
      return AppBar(
        title: Text('Anlässe'),
        actions: [
          AppBarSearchButton(),
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
          const AppBarUserAvatar(),
        ],
      );
    },
  );
}