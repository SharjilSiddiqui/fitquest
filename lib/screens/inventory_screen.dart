import 'package:flutter/material.dart';

import '../models/player_data.dart';
import '../services/rpg_service.dart';
import '../widgets/fitquest_dashboard.dart';

enum InventoryCategory {
  all('All'),
  consumables('Consumables'),
  weapons('Weapons'),
  armor('Armor'),
  accessories('Accessories');

  const InventoryCategory(this.label);

  final String label;
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    super.key,
    required this.player,
    required this.getPlayer,
    required this.onUseItem,
    required this.onEquipItem,
    required this.onOpenChest,
    required this.onGoToShop,
  });

  final PlayerData player;
  final PlayerData Function() getPlayer;
  final ValueChanged<String> onUseItem;
  final ValueChanged<String> onEquipItem;
  final ValueChanged<String> onOpenChest;
  final VoidCallback onGoToShop;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late PlayerData _player = widget.player;
  InventoryCategory _category = InventoryCategory.all;

  void _refreshAfter(VoidCallback action) {
    action();
    setState(() => _player = widget.getPlayer());
  }

  @override
  Widget build(BuildContext context) {
    final itemCounts = _itemCounts(_filteredInventory());

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            RpgCard(
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.inventory_2)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text('Total Items: ${_player.inventory.length}'),
                      ],
                    ),
                  ),
                  InfoChip(icon: Icons.paid, label: '${_player.gold} Gold'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<InventoryCategory>(
                selected: {_category},
                onSelectionChanged: (selection) {
                  setState(() => _category = selection.first);
                },
                segments: InventoryCategory.values
                    .map(
                      (category) => ButtonSegment(
                        value: category,
                        label: Text(category.label),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (_player.inventory.isEmpty)
              EmptyInventoryCard(onGoToShop: widget.onGoToShop)
            else if (itemCounts.isEmpty)
              const RpgCard(child: Text('No items in this category.'))
            else
              ...itemCounts.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FullInventoryItemCard(
                    itemName: entry.key,
                    count: entry.value,
                    equipped: _isEquipped(entry.key),
                    onUse: () =>
                        _refreshAfter(() => widget.onUseItem(entry.key)),
                    onEquip: () =>
                        _refreshAfter(() => widget.onEquipItem(entry.key)),
                    onOpen: () =>
                        _refreshAfter(() => widget.onOpenChest(entry.key)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _filteredInventory() {
    return _player.inventory.where((itemName) {
      switch (_category) {
        case InventoryCategory.all:
          return true;
        case InventoryCategory.consumables:
          return RpgService.isConsumable(itemName);
        case InventoryCategory.weapons:
          return itemName == RpgService.ironSword;
        case InventoryCategory.armor:
          return itemName == RpgService.steelArmor;
        case InventoryCategory.accessories:
          return itemName == RpgService.magicRing;
      }
    }).toList();
  }

  Map<String, int> _itemCounts(List<String> inventory) {
    final counts = <String, int>{};
    for (final itemName in inventory) {
      counts[itemName] = (counts[itemName] ?? 0) + 1;
    }
    return counts;
  }

  bool _isEquipped(String itemName) {
    return _player.equippedWeapon == itemName ||
        _player.equippedArmor == itemName ||
        _player.equippedAccessory == itemName;
  }
}

class FullInventoryItemCard extends StatelessWidget {
  const FullInventoryItemCard({
    super.key,
    required this.itemName,
    required this.count,
    required this.equipped,
    required this.onUse,
    required this.onEquip,
    required this.onOpen,
  });

  final String itemName;
  final int count;
  final bool equipped;
  final VoidCallback onUse;
  final VoidCallback onEquip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isConsumable = RpgService.isConsumable(itemName);
    final isEquippable = RpgService.isEquippable(itemName);
    final isChest = RpgService.isChest(itemName);

    return RpgCard(
      child: Row(
        children: [
          CircleAvatar(child: Icon(iconForItem(itemName))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(RpgService.itemTypeLabel(itemName)),
                const SizedBox(height: 4),
                Text('${RpgService.itemEffectLabel(itemName)} • Owned: $count'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isConsumable)
            FilledButton(onPressed: onUse, child: const Text('Use'))
          else if (isEquippable)
            FilledButton(
              onPressed: equipped ? null : onEquip,
              child: Text(equipped ? 'Equipped' : 'Equip'),
            )
          else if (isChest)
            FilledButton(onPressed: onOpen, child: const Text('Open')),
        ],
      ),
    );
  }
}

class EmptyInventoryCard extends StatelessWidget {
  const EmptyInventoryCard({super.key, required this.onGoToShop});

  final VoidCallback onGoToShop;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No items in inventory',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onGoToShop,
              icon: const Icon(Icons.storefront),
              label: const Text('Go To Shop'),
            ),
          ],
        ),
      ),
    );
  }
}
