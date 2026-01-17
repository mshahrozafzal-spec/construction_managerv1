static const String materialCatalog = '/materials/catalog';
static const String costControl = '/materials/cost-control';

static Map<String, WidgetBuilder> get routes {
  return {
    // ... existing routes
    AppRoutes.materialCatalog: (context) => const MaterialCatalogScreen(),
    AppRoutes.costControl: (context) => const CostControlScreen(),
  };
}