// ignore_for_file: avoid_print

import 'package:creatico/features/chat/bloc/chat_bloc.dart';
import 'package:creatico/features/chat/bloc/chat_state.dart';
import 'package:creatico/features/idea/presentation/widgets/appbar.dart';
import 'package:creatico/features/idea/presentation/widgets/chatinputbar.dart';
import 'package:creatico/features/idea/presentation/widgets/chatmessages_list.dart';
import 'package:creatico/features/idea/presentation/widgets/herotagline.dart';
import 'package:creatico/features/idea/presentation/widgets/platfrom_selection_drawer.dart';
import 'package:creatico/features/idea/presentation/widgets/sidebar_drawer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdeaChatScreen extends StatefulWidget {
  const IdeaChatScreen({super.key});

  @override
  State<IdeaChatScreen> createState() => _IdeaChatScreenState();
}

class _IdeaChatScreenState extends State<IdeaChatScreen> with SingleTickerProviderStateMixin {
  late AnimationController _platformDrawerController;
  late Animation<Offset> _platformDrawerOffset;

  bool _isDrawerOpen = false;
  String? _selectedProviderName;
  String? _selectedProviderId;

  @override
  void initState() {
    super.initState();
    _platformDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _platformDrawerOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _platformDrawerController,
      curve: Curves.easeOutCubic,
    ));
  }

  void togglePlatformDrawer() {
    if (_isDrawerOpen) {
      _platformDrawerController.reverse();
    } else {
      _platformDrawerController.forward();
    }
    _isDrawerOpen = !_isDrawerOpen;
  }
  
  void _onPlatformSelected(String providerName, String providerId) {
    setState(() {
      _selectedProviderName = providerName;
      _selectedProviderId = providerId;
    });
    togglePlatformDrawer();
  }

  @override
  void dispose() {
    _platformDrawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const CustomDrawer(),
      appBar: AppBarWidget(
        showMessageIcon: true, // toggle based on chat view / history
        onMessageTap: () {
          // Toggle show in current chat / history
        },
      ),
      body: Stack(
        children: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final chatBloc = context.read<ChatBloc>();
              final hasMessages = chatBloc.messages.isNotEmpty;

              return Column(
                children: [
                  if (!hasMessages) const HeroTaglineWidget(),
                  const Expanded(child: ChatMessagesListWidget()),
                ],
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _platformDrawerOffset,
                  child: PlatformSelectionDrawerWidget(
                    onProviderSelected: _onPlatformSelected,
                    selectedProviderName: _selectedProviderName,
                    selectedProviderId: _selectedProviderId,
                  ),
                ),
                ChatInputBarWidget(
                  onPlatformTap: togglePlatformDrawer,
                  onVoiceTap: () => print("Voice command activated"),
                  selectedProviderName: _selectedProviderName,
                  selectedProviderId: _selectedProviderId,
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
