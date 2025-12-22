class OnboardingItem {
  final String title;
  final String description;
  final String imagePath; // Или IconData, если используете иконки

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
