import '../models/boss.dart';
import '../models/player_data.dart';
import '../models/shop_item.dart';
import '../services/xp_service.dart';

class RpgService {
  static const smallXpPotion = 'Small XP Potion';
  static const largeXpPotion = 'Large XP Potion';
  static const ironSword = 'Iron Sword';
  static const steelArmor = 'Steel Armor';
  static const magicRing = 'Magic Ring';
  static const epicChest = 'Epic Chest';

  static const shopItems = [
    ShopItem(
      name: smallXpPotion,
      cost: 100,
      type: ItemType.consumable,
      description: '+50 XP',
    ),
    ShopItem(
      name: largeXpPotion,
      cost: 300,
      type: ItemType.consumable,
      description: '+200 XP',
    ),
    ShopItem(
      name: ironSword,
      cost: 500,
      type: ItemType.weapon,
      description: '+5 Strength',
    ),
    ShopItem(
      name: steelArmor,
      cost: 500,
      type: ItemType.armor,
      description: '+5 Vitality',
    ),
    ShopItem(
      name: magicRing,
      cost: 750,
      type: ItemType.accessory,
      description: '+5 Wisdom',
    ),
    ShopItem(
      name: epicChest,
      cost: 1000,
      type: ItemType.chest,
      description: 'A rare trophy item',
    ),
  ];

  static const bosses = [
    Boss(name: 'Goblin King', hp: 100, rewardGold: 100, rewardXp: 100),
    Boss(name: 'Forest Troll', hp: 250, rewardGold: 250, rewardXp: 250),
    Boss(name: 'Dragon Whelp', hp: 500, rewardGold: 500, rewardXp: 500),
  ];

  static int rewardAmountForDay(int day) {
    switch (day) {
      case 1:
        return 20;
      case 2:
        return 30;
      case 3:
        return 50;
      case 4:
        return 75;
      case 5:
        return 100;
      case 6:
        return 150;
      default:
        return 0;
    }
  }

  static String rewardLabelForDay(int day) {
    if (day == 7) return epicChest;
    return '${rewardAmountForDay(day)} Gold';
  }

  static bool isRewardClaimedToday(PlayerData player) {
    return player.lastRewardClaimDate == todayKey();
  }

  static String todayKey() {
    final today = DateTime.now();
    return '${today.year}-${today.month}-${today.day}';
  }

  static int strengthBonus(PlayerData player) {
    return player.equippedWeapon == ironSword ? 5 : 0;
  }

  static int agilityBonus(PlayerData player) {
    return 0;
  }

  static int wisdomBonus(PlayerData player) {
    return player.equippedAccessory == magicRing ? 5 : 0;
  }

  static int vitalityBonus(PlayerData player) {
    return player.equippedArmor == steelArmor ? 5 : 0;
  }

  static int totalStrength(PlayerData player) {
    return player.strength + strengthBonus(player);
  }

  static int totalAgility(PlayerData player) {
    return player.agility + agilityBonus(player);
  }

  static int totalWisdom(PlayerData player) {
    return player.wisdom + wisdomBonus(player);
  }

  static int totalVitality(PlayerData player) {
    return player.vitality + vitalityBonus(player);
  }

  static int playerPower(PlayerData player) {
    return totalStrength(player) +
        totalAgility(player) +
        totalWisdom(player) +
        totalVitality(player) +
        XpService.levelFromXp(player.xp);
  }

  static Boss bossByName(String name) {
    return bosses.firstWhere((boss) => boss.name == name);
  }

  static ShopItem itemByName(String name) {
    return shopItems.firstWhere((item) => item.name == name);
  }

  static bool isConsumable(String name) {
    return name == smallXpPotion || name == largeXpPotion;
  }

  static bool isEquippable(String name) {
    return name == ironSword || name == steelArmor || name == magicRing;
  }

  static String itemTypeLabel(String name) {
    if (name == smallXpPotion || name == largeXpPotion) return 'Consumable';
    if (name == ironSword) return 'Weapon';
    if (name == steelArmor) return 'Armor';
    if (name == magicRing) return 'Accessory';
    if (name == epicChest) return 'Chest';
    return 'Item';
  }

  static String itemEffectLabel(String name) {
    if (name == smallXpPotion) return '+50 XP';
    if (name == largeXpPotion) return '+200 XP';
    if (name == ironSword) return 'Attack +5';
    if (name == steelArmor) return 'Defense +10';
    if (name == magicRing) return 'Wisdom +5';
    if (name == epicChest) return 'Open for rewards';
    return 'Stored item';
  }

  static bool isChest(String name) {
    return name == epicChest;
  }
}
