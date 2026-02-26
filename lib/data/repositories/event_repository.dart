import 'package:commercia/business/images.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRepository {
  Future<List<EventModel>> getEvents() async {
    List<EventModel> events = [];

    //Date & time formatting
    final timeShort = new DateFormat('H:mm', 'de_CH');
    final dateShort = new DateFormat('EEEE, d. MMM', 'de_CH');
    final dateLong = new DateFormat('EEEE, d. MMMM y', 'de_CH');

    final results = await Supabase.instance.client
        .from('events')
        .select()
        .gte('date', DateTime.now().toString())
        .order('date', ascending: true);

    for (var result in results) {
      try {

        // Date & Time parsing
        DateTime date = DateTime.parse(result['date']); //.toUtc();

        var timeMeet = result['time_meet'];
        if (timeMeet == null) timeMeet = result['time_start'];
        
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final startDt = DateTime.parse(dateStr + "T" + result['time_start']); // local, no Z
        final endDt   = DateTime.parse(dateStr + "T" + result['time_end']);   // local, no Z

        String time_meet = timeShort.format(DateTime.parse(dateStr + "T" + timeMeet));
        String time_start = timeShort.format(DateTime.parse(dateStr + "T" + result['time_start']));
        String time_end = timeShort.format(DateTime.parse(dateStr + "T" + result['time_end']));

        // Tenu text
        String tenue = '';
        switch (result['tenue']) {
          case 1:
            tenue = 'Farben';
            break;
          case 2:
            tenue = 'Légère';
            break;
          case 3:
            tenue = 'Sport';
            break;
        }

        // Cost parsing
        String cost = result['cost'].toString();
        String cost_ak = result['cost_ak'].toString();
        String cost_text = '';
        String cost_show = '';

        if (cost == '0') {
          cost_show = 'dont';
        } else if (cost_ak != null && cost_ak != '') {
          cost = cost + ' CHF für Altherren';
          cost_ak = cost_ak + ' CHF für Aktive';
          cost_show = 'both';
        } else {
          cost = cost + ' CHF';
          cost_show = 'one';
        }

        // Location parsing
        String? location;
        String location_meet;
        location = result['location'] as String?;
        location_meet = result['location_meet'] ?? '';
        if (location_meet == '') {
          if (location == null || location == '') {
            location_meet = 'Ort folgt';
          } else {
          location_meet = location;
          }
        } else {
          location_meet = result['location_meet'];
        }

        // Card info
        String card_text = '';
        if (result['details_tbd']) {
          card_text = 'Details folgen';
        } else {
          card_text =
              time_meet + ' · ' + location_meet + ' · ' + tenue;
        }

        events.add(EventModel(
            id: result['uuid'],
            title: result['title'],
            subtitle: result['subtitle'] ?? '',
            //image: ImageUtils.getImageUrl(result['image']), //Web
            image: ImageUtils.getImageLocal(result['image'], 'event'), //Local
            date: date,
            date_long: dateLong.format(date),
            date_short: dateShort.format(date),
            time_meet: time_meet,
            time_start: time_start,
            time_end: time_end,
            time_text: time_meet + ' - ' + time_end,
            start_dt: startDt,
            end_dt: endDt,
            location: location,
            location_meet: location_meet,
            location_details: result['location_details'] ?? '',
            cost_show: cost_show,
            cost: cost,
            cost_ak: cost_ak,
            signup_url: result['signup_url'],
            tenue_text: tenue,
            club: result['club'],
            details: result['details'],
            card_text: card_text));
      } catch (e) {
        print('Error parsing event: $e');
      }
    }

    events.sort((a, b) => a.date!.compareTo(b.date!));

    return events;
  }
}