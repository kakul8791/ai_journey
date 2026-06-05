class SeasonHelper {
  static Map<String, String> getSeason(String dest, int month) {
    final seasons = <String, Map<String, List<int>>>{
      'Manali': {
        'good': [4, 5, 8, 9],
        'ok': [3, 10],
        'bad': [0, 1, 2, 6, 7, 11],
      },
      'Goa': {
        'good': [10, 11, 0, 1],
        'ok': [9, 2],
        'bad': [3, 4, 5, 6, 7, 8],
      },
      'Jaipur': {
        'good': [9, 10, 11, 0, 1],
        'ok': [8, 2],
        'bad': [3, 4, 5, 6, 7],
      },
      'Kerala': {
        'good': [10, 11, 0, 1, 8, 9],
        'ok': [2, 7],
        'bad': [3, 4, 5, 6],
      },
      'Shimla': {
        'good': [3, 4, 5, 9, 10],
        'ok': [6, 8],
        'bad': [0, 1, 2, 7, 11],
      },
      'Nainital': {
        'good': [3, 4, 5, 9, 10],
        'ok': [6, 8],
        'bad': [0, 1, 2, 7, 11],
      },
    };

    final s = seasons[dest] ?? {
      'good': [9, 10, 11, 0, 1],
      'ok': [8, 2],
      'bad': [3, 4, 5, 6, 7],
    };

    if (s['good']!.contains(month)) {
      return {
        'cls': 'good',
        'label': '✅ Best Season',
        'tip': 'Abhi jaana bilkul sahi rahega! Mausam best hoga.',
      };
    } else if (s['ok']!.contains(month)) {
      return {
        'cls': 'ok',
        'label': '🟡 Theek Hai',
        'tip': 'Average season hai — crowd kam hoga, price bhi.',
      };
    } else {
      return {
        'cls': 'bad',
        'label': '❌ Off Season',
        'tip': 'Is waqt avoid karo — better season ka wait karo.',
      };
    }
  }
}