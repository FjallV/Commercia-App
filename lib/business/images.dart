//import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUtils {
  static getImageUrl(String image) {
    final String publicUrl = Supabase.instance.client.storage
        .from('commercia')
        .getPublicUrl('events/$image.png');

    return publicUrl;
  }

  static getImageLocal(String image, String? type) {
    if (type == null || type == '') {
      type = 'event';
    }

    image = image.toLowerCase();

    String localUrl = 'assets/images/$type/$image.png';

    // if(File(localUrl).exists() == false) {
    //   localUrl = 'assets/images/$type/default.png';
    // }

    return localUrl;
  }
}
