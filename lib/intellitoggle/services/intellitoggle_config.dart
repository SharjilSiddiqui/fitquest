class IntellitoggleConfig {
  static const String environment = String.fromEnvironment(
    'INTELLITOGGLE_ENVIRONMENT',
    defaultValue: 'browser-demo',
  );

  static const String projectId = String.fromEnvironment(
    'INTELLITOGGLE_PROJECT_ID',
    defaultValue: 'fitquest',
  );
}
