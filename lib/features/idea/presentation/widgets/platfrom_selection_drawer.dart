// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PlatformSelectionDrawerWidget extends StatelessWidget {
  final void Function(String providerName, String providerId) onProviderSelected;
  final String? selectedProviderName;
  final String? selectedProviderId;

  const PlatformSelectionDrawerWidget({
    super.key, 
    required this.onProviderSelected,
    this.selectedProviderName,
    this.selectedProviderId,
  });

  final Map<String, Map<String, dynamic>> platforms = const {
'openai': { // Example built-ins for convenience
      'name': 'OpenAI',
      'color': Colors.green,
      'description': 'GPT-4, GPT-3.5',
    },
    'grok': {
      'name': 'Grok',
      'color': Colors.orange,
      'description': 'X.AI',
    },
    'anthropic': {
      'name': 'Anthropic',
      'color': Colors.purple,
      'description': 'Claude',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select AI Provider',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: platforms.entries
                .map(
                  (entry) {
                    final platformKey = entry.key;
                    final platformData = entry.value;
                    final isSelected = selectedProviderName == platformData['name'];
                    
                    return GestureDetector(
                      onTap: () => onProviderSelected(platformData['name'] as String, platformKey),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? (platformData['color'] as Color).withOpacity(0.2)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: platformData['color'] as Color, width: 1)
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              platformData['name'] as String,
                              style: TextStyle(
                                color: isSelected 
                                    ? platformData['color'] as Color
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (selectedProviderId != null && selectedProviderId == platformKey)
                              const Text(
                                '(selected)',
                                style: TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              platformData['description'] as String,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
