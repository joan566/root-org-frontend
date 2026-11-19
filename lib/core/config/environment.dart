enum Environment {
  development,
  staging,
  production;

  static Environment parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'development' => Environment.development,
      'staging' => Environment.staging,
      'production' => Environment.production,
      _ => throw FormatException(
        'Unknown APP_ENV "$value". Expected development, staging, or production.',
      ),
    };
  }
}
