enum Flavor { dev, qa, staging, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return '(Dev) Petrasoft School Management Solutions';
      case Flavor.qa:
        return '(QA) Petrasoft School Management Solutions';
      case Flavor.staging:
        return '(Staging) Petrasoft School Management Solutions';
      case Flavor.prod:
        return 'Petrasoft School Management Solutions';
    }
  }
}
