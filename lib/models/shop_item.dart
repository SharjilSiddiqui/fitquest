enum ItemType { consumable, weapon, armor, accessory, chest }

class ShopItem {
  const ShopItem({
    required this.name,
    required this.cost,
    required this.type,
    required this.description,
  });

  final String name;
  final int cost;
  final ItemType type;
  final String description;
}
