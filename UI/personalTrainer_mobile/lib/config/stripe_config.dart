class StripeConfig {
  // Publishable key fallback for local debug when --dart-define is not applied.
  static const publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51T3mm2J0jiiSNJ3blaJUkoD6Wb3vlb7TXbuaVPRvZcqcnR97wbKE9SUGS6zFy6Zo39yYKTxT9Ak8SvuOBe0pyqqK00qlBz8Evl',
  );

  static bool get isValid =>
      publishableKey.isNotEmpty && publishableKey.startsWith('pk_');
}