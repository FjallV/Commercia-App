import 'package:commercia/business/images.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRepository {
  Future<List<EventModel>> getEvents() async {
    List<EventModel> events = [];
      //Date and time
      final timeShort = new DateFormat('H:mm', 'de_CH');
      final dateShort = new DateFormat('EEEE, d. MMM', 'de_CH');
      final dateLong = new DateFormat('EEEE, d. MMMM y', 'de_CH');

    final results = await Supabase.instance.client.from('events').select().gte('date', DateTime.now().toString()).order('date', ascending: true);

    for (var result in results) {
      try{
      DateTime date = DateTime.parse(result['date']);


      // DateTime date_start = DateTime.parse(result['date_start']) + ;
      // DateTime date_end = DateTime.parse(result['date_end']);

      String time_meet = timeShort.format(DateTime.parse(
          DateFormat('yyyy-MM-dd').format(date) +
              "T" +
              result['time_meet']));
      String time_start = timeShort.format(DateTime.parse(
          DateFormat('yyyy-MM-dd').format(date) +
              "T" +
              result['time_start']));
      String time_end = timeShort.format(DateTime.parse(
          DateFormat('yyyy-MM-dd').format(date) + //DateTime.now
              "T" +
              result['time_end']));

      // Tenu
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

      // Cost
      String cost = result['cost'].toString();
      String cost_ak = result['cost_ak'].toString();
      String cost_text = '';
      String cost_show = '';

      if (cost == '0') {
        cost_show = 'dont';
      } else if (cost_ak != 'null' && cost_ak != '') {
        cost = cost + ' CHF für Altherren';
        cost_ak = cost_ak + ' CHF für Aktive';
        cost_show = 'both';
      } else {
        cost = cost + ' CHF';
        cost_show = 'one';
      }

      String card_text = '';
      if(result['details_tbd']) {
        card_text = 'Details folgen';
      } else {
        card_text = time_meet + ' · ' + result['location_meet'] + ' · ' + tenue;
      }

      events.add(EventModel(
        id: result['uuid'],
        title: result['title'],
        subtitle: result['subtitle'],
        //image: ImageUtils.getImageUrl(result['image']), //Web
        image: ImageUtils.getImageLocal(result['image'], 'event'), //Local
        date: date,
        date_long: dateLong.format(date),
        date_short: dateShort.format(date),
        time_meet: time_meet,
        time_start: time_start,
        time_end: time_end,
        time_text: time_meet + ' - ' + time_end,
        location: result['location'],
        location_meet: result['location_meet'],
        location_details: result['location_details'],
        cost_show: cost_show,
        cost: cost,
        cost_ak: cost_ak,
        signup_url: result['signup_url'],
        tenue_text: tenue,
        details: result['details'],
        card_text: card_text
            
      ));

      } catch (e) {
        print('Error parsing event: $e');
      }
    }

    events.sort((a, b) => a.date!.compareTo(b.date!));

    return events;
  }
}
