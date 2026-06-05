class TripPlan {
  final String from;
  final String to;
  final int budgetPerPerson;
  final int persons;
  final DateTime travelDate;
  final String travelMode;

  TripPlan({
    required this.from,
    required this.to,
    required this.budgetPerPerson,
    required this.persons,
    required this.travelDate,
    required this.travelMode,
  });

  int get totalBudget => budgetPerPerson * persons;
}