// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';

class DrawerHeaderWithSearch extends StatefulWidget {
  const DrawerHeaderWithSearch({super.key});

  @override
  State<DrawerHeaderWithSearch> createState() => _DrawerHeaderWithSearchState();
}

class _DrawerHeaderWithSearchState extends State<DrawerHeaderWithSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      decoration: InputDecoration(
                      
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16.0,
                        ),
                        border: InputBorder.none,
                      ),
                      // Listener to update the state when the text changes
                      onChanged: (text) {
                        setState(() {});
                      },
                      onSubmitted: (text) {
                        
                        print('Searching for: $text');
                      },
                    ),
                  ),
                  // Clear icon that only appears when there's text in the field
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      onPressed: () {
                        // Clear the text and reset the state
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Icon(
            Icons.edit_outlined,
            color: Colors.white.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
