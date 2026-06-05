import 'trip_plan.dart';

class RouteOption {
  final String name;
  final String icon;
  final int costPerPerson;
  final String duration;
  final String badge;
  final String comfort;
  final List<String> steps;
  final String tip;
  final bool isBestValue;
  final bool isSelfDrive;

  RouteOption({
    required this.name,
    required this.icon,
    required this.costPerPerson,
    required this.duration,
    required this.badge,
    required this.comfort,
    required this.steps,
    required this.tip,
    this.isBestValue = false,
    this.isSelfDrive = false,
  });

  static List<RouteOption> getRoutes(TripPlan plan) {
    final b = plan.budgetPerPerson;
    final List<RouteOption> routes = [];

    if (plan.travelMode == 'bus' || plan.travelMode == 'any') {
      final cost = (b * 0.35).round().clamp(0, 900);
      routes.add(RouteOption(
        name: 'Seedhi Bus',
        icon: '🚌',
        costPerPerson: cost,
        duration: '8-10 ghante',
        comfort: '★★☆☆☆',
        badge: 'Sabse Sasta',
        steps: [
          '${plan.from} Bus Stand se direct bus lo',
          'Sleeper / AC options available hain',
          'Cost: ₹$cost per person',
        ],
        tip: cost <= b
            ? '✅ Budget ke andar!'
            : '⚠️ Thoda upar ho sakta hai',
      ));
    }

    if (plan.travelMode == 'train' || plan.travelMode == 'any') {
      final cost = (b * 0.45).round().clamp(0, 1200);
      routes.add(RouteOption(
        name: 'Train + Local',
        icon: '🚆',
        costPerPerson: cost,
        duration: '6-9 ghante',
        comfort: '★★★☆☆',
        badge: 'Best Value',
        isBestValue: true,
        steps: [
          '${plan.from} se nearest railhead tak train lo',
          'Last 30km ke liye local taxi ya bus',
          'Cost: ₹$cost per person',
        ],
        tip: cost <= b
            ? '✅ Budget fit! Recommended route.'
            : '⚠️ Budget thoda stretch hoga',
      ));
    }

    if (plan.travelMode == 'car' || plan.travelMode == 'any') {
      final cost = (b * 0.55).round();
      routes.add(RouteOption(
        name: 'Self Drive Car',
        icon: '🚗',
        costPerPerson: cost,
        duration: '7-8 ghante',
        comfort: '★★★★☆',
        badge: 'Freedom!',
        isSelfDrive: true,
        steps: [
          'Self drive car book karo — 24hr rental',
          'Petrol ₹${(cost * 0.5).round()} (shared cost)',
          'Best time: 5 AM start — jam avoid hoga',
        ],
        tip: '⏰ Early morning niklo — NH pe jam nahi milta',
      ));
    }

    return routes;
  }
}