class ExtraService {
  static const String FIELD_ID = "id";
  static const String FIELD_TITLE = "title";
  static const String FIELD_DESCRIPTION = "description";
  static const String FIELD_PRICE = "price";

  final String id;
  final String title;
  final String description;
  final double price;

  ExtraService(this.id, this.title, this.description, this.price);

  ExtraService.fromMap(Map<dynamic, dynamic> map)
      : assert(map[FIELD_ID] != null),
        assert(map[FIELD_TITLE] != null),
        assert(map[FIELD_DESCRIPTION] != null),
        assert(map[FIELD_PRICE] != null),
        id = map[FIELD_ID],
        title = map[FIELD_TITLE],
        description = map[FIELD_DESCRIPTION],
        price = map[FIELD_PRICE];

  static List<ExtraService> fromListOfMaps(List<dynamic> list) {
    if (list == null) return List();
    var newList = List<ExtraService>();
    list.forEach((it) {
      newList.add(ExtraService.fromMap(it));
    });
    return newList;
  }
}

class ServiceCount extends ExtraService {
  static const String FIELD_COUNT = "count";

  final int count;

  ServiceCount(
      String id, String title, String description, double price, this.count)
      : super(id, title, description, price);

  static ServiceCount fromMap(Map<dynamic, dynamic> map) {
    assert(map[ExtraService.FIELD_ID] != null);
    assert(map[ExtraService.FIELD_TITLE] != null);
    assert(map[ExtraService.FIELD_DESCRIPTION] != null);
    assert(map[ExtraService.FIELD_PRICE] != null);

    return ServiceCount(
        map[ExtraService.FIELD_ID],
        map[ExtraService.FIELD_TITLE],
        map[ExtraService.FIELD_DESCRIPTION],
        map[ExtraService.FIELD_PRICE],
        map[FIELD_COUNT] ?? 0);
  }

  static List<ExtraService> fromListOfMaps(List<dynamic> list) {
    if (list == null) return null;
    var newList = List<ServiceCount>();
    list.forEach((it) {
      newList.add(ServiceCount.fromMap(it));
    });
    return newList;
  }

  static ServiceCount fromExtraService(ExtraService extraService) {
    return ServiceCount(extraService.id, extraService.title,
        extraService.description, extraService.price, 0);
  }

  ServiceCount copyWith(
      {String id, String title, String description, double price, int count}) {
    return ServiceCount(
        id ?? this.id,
        title ?? this.title,
        description ?? this.description,
        price ?? this.price,
        count ?? this.count);
  }
}
