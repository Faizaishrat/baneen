class RideModel {
  final String id;
  final String passengerId;
  final String? driverId;
  final String status; // pending, accepted, in_progress, completed, cancelled
  final LocationModel pickupLocation;
  final LocationModel destinationLocation;
  final double? fare;
  final double? estimatedFare;
  final String? vehicleType;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final String? paymentMethod;
  final bool isPaid;
  final double? rating;
  final String? review;
  final String? cancellationReason;
  final String? cancelledBy; // 'passenger' or 'driver'

  RideModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.status,
    required this.pickupLocation,
    required this.destinationLocation,
    this.fare,
    this.estimatedFare,
    this.vehicleType,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.paymentMethod,
    this.isPaid = false,
    this.rating,
    this.review,
    this.cancellationReason,
    this.cancelledBy,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['_id'] ?? json['id'] ?? '',
      passengerId: json['passengerId'] ?? '',
      driverId: json['driverId'],
      status: json['status'] ?? 'pending',
      pickupLocation: LocationModel.fromJson(json['pickupLocation'] ?? {}),
      destinationLocation: LocationModel.fromJson(json['destinationLocation'] ?? {}),
      fare: json['fare'] != null ? (json['fare'] as num).toDouble() : null,
      estimatedFare: json['estimatedFare'] != null
          ? (json['estimatedFare'] as num).toDouble()
          : null,
      vehicleType: json['vehicleType'],
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      paymentMethod: json['paymentMethod'],
      isPaid: json['isPaid'] ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      review: json['review'],
      cancellationReason: json['cancellationReason'],
      cancelledBy: json['cancelledBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'status': status,
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'fare': fare,
      'estimatedFare': estimatedFare,
      'vehicleType': vehicleType,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'rating': rating,
      'review': review,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
    };
  }
}

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0) as double,
      longitude: (json['longitude'] ?? json['lng'] ?? json['lon'] ?? 0.0) as double,
      address: json['address'],
      placeId: json['placeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeId': placeId,
    };
  }
}

