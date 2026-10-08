abstract interface class TutorService {
  Future<String> reply(String prompt);
}

abstract interface class SpeakingPracticeService {
  Future<double> assess(String languageCode, String phrase);
}

abstract interface class PersonalizationService {
  Future<List<String>> suggestNextSteps(
      String ageGroup, List<String> completedTopics);
}

abstract interface class BillingService {
  Future<List<PremiumProduct>> products();
  Future<bool> purchase(String productId);
}

class PremiumProduct {
  const PremiumProduct(
      {required this.id, required this.name, required this.priceLabel});
  final String id;
  final String name;
  final String priceLabel;
}
