import 'package:commercia/data/models/event_model.dart';
import 'package:commercia/data/repositories/event_repository.dart';
import 'package:flutter/widgets.dart';

class EventViewModel extends ChangeNotifier {
  EventViewModel({
    required EventRepository eventRepository,
  }) : _eventRepository = eventRepository;

  final EventRepository _eventRepository;

  List<EventModel> _events = [];
  List<EventModel> get events => _events;

  Future<List<EventModel>> load() async {
    try {
      final eventResult = await _eventRepository.getEvents();
      // switch (eventResult) {
      //    case Ok<Event>():
      //     _user = userResult.value;
      //     _log.fine('Loaded user');
      //   case Error<Event>():
      //     _log.warning('Failed to load events', eventResult.error);
      // }

      // ...
      _events = eventResult;
      print('Events geladen');
      return eventResult;
    } finally {
      notifyListeners();
    }
  }
}
