typedef Json = Map<String, dynamic>;

class PageData<T> {
  final List<T> items;
  final int page, totalPages, totalCount;
  const PageData(this.items, this.page, this.totalPages, this.totalCount);
  bool get hasNext => page < totalPages;
  factory PageData.fromJson(Json json, T Function(Json) parse) {
    final pagination = Map<String, dynamic>.from(json['pagination'] ?? {});
    return PageData(
      (json['data'] as List? ?? [])
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList(),
      pagination['pageNumber'] ?? 1,
      pagination['totalPages'] ?? 1,
      pagination['totalCount'] ?? 0,
    );
  }
}

class CursorPageData<T> {
  final List<T> items;
  final int? nextCursor;
  final bool hasNextPage;
  final int pageSize;

  const CursorPageData({
    required this.items,
    this.nextCursor,
    required this.hasNextPage,
    required this.pageSize,
  });

  factory CursorPageData.fromJson(Json json, T Function(Json) parse) {
    final pagination = Map<String, dynamic>.from(json['pagination'] ?? {});
    return CursorPageData(
      items: (json['data'] as List? ?? [])
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList(),
      nextCursor: pagination['nextCursor'],
      hasNextPage: pagination['hasNextPage'] == true,
      pageSize: pagination['pageSize'] ?? 15,
    );
  }
}

const donationTypes = [
  'နဝကမ္မ',
  'ဆွမ်း',
  'ဆေးဝါး',
  'သင်္ကန်း',
  'လှူဖွယ်ဝတ္ထု',
  'အခြား',
];
const donationStatuses = [
  'စောင့်ဆိုင်းဆဲ',
  'လက်ခံပြီး',
  'ဆွမ်းချိန် သတ်မှတ်ပြီး',
  'ကပ်လှူပြီးစီး',
  'လက်မခံနိုင်ပါ',
  'ပယ်ဖျက်ပြီး',
];

class DonationStatusItem {
  final int id;
  final String name, label;
  const DonationStatusItem({
    required this.id,
    required this.name,
    required this.label,
  });
  factory DonationStatusItem.fromJson(Json json) => DonationStatusItem(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    name: json['name']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
  );
}
const spaceRoles = {
  1: 'ကျောင်းထိုင်ဆရာတော်',
  2: 'စီမံခန့်ခွဲသူ',
  3: 'စာရင်းကိုင်/တာဝန်ခံ',
  4: 'အဖွဲ့ဝင်',
};

class Monastery {
  final int id;
  final String name, address, description;
  final int? roleId;
  final bool isOwner;
  const Monastery({
    required this.id,
    required this.name,
    this.address = '',
    this.description = '',
    this.roleId,
    this.isOwner = false,
  });
  factory Monastery.fromJson(Json json) => Monastery(
    id: json['id'],
    name: json['monasteryName'] ?? '',
    address: json['address'] ?? '',
    description: json['description'] ?? '',
    roleId: json['currentUserRoleId'],
    isOwner: json['isOwner'] == true,
  );
  bool get isMember => isOwner || roleId != null;
  // Default space roles from backend seeds. Server rechecks every mutation.
  bool get canManage => isOwner || roleId == 1 || roleId == 2;
  bool get canOperate => canManage || roleId == 3;
}

class Donation {
  final int id, monasteryId, type, status;
  final int? donorId;
  final String donorName, note, customType;
  final num? amount, quantity;
  final DateTime? pickup, dropoff, created, completed;
  const Donation({
    required this.id,
    required this.monasteryId,
    required this.type,
    required this.status,
    this.donorId,
    this.donorName = '',
    this.note = '',
    this.customType = '',
    this.amount,
    this.quantity,
    this.pickup,
    this.dropoff,
    this.created,
    this.completed,
  });
  factory Donation.fromJson(Json json) => Donation(
    id: json['id'],
    monasteryId: json['monasterySpaceId'],
    type: json['donationType'],
    status: json['status'],
    donorId: json['donorId'],
    donorName: json['donorName'] ?? '',
    note: json['note'] ?? '',
    customType: json['customDonationType'] ?? '',
    amount: json['amount'],
    quantity: json['quantity'],
    pickup: DateTime.tryParse(json['pickupTime'] ?? ''),
    dropoff: DateTime.tryParse(json['dropoffTime'] ?? ''),
    created: DateTime.tryParse(json['createdAt'] ?? ''),
    completed: DateTime.tryParse(json['completedAt'] ?? ''),
  );
  String get typeLabel =>
      type >= 0 && type < donationTypes.length ? donationTypes[type] : 'အခြား';
  String get statusLabel => status >= 0 && status < donationStatuses.length
      ? donationStatuses[status]
      : '—';
  bool get isActive => status != 3 && status != 4 && status != 5;
}

class CalendarSummary {
  final int count;
  final num amount;
  final List<Json> days;
  const CalendarSummary(this.count, this.amount, this.days);
  factory CalendarSummary.fromJson(Json json) => CalendarSummary(
    json['totalDonationsCount'] ?? 0,
    json['totalAmount'] ?? 0,
    (json['days'] as List? ?? []).map((e) => Json.from(e)).toList(),
  );
}
