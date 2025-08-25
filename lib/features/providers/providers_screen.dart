// lib/features/providers/providers_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/api_provider_model.dart';
import '../../core/services/provider_service.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final ProviderService _providerService = ProviderService();
  List<ApiProviderModel> _providers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Ensure we have a session before calling backend
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Please sign in to load providers';
        });
        return;
      }
      
      final providers = await _providerService.getProviders();
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddProviderDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddProviderDialog(
        onProviderAdded: (provider) {
          setState(() {
            _providers.add(provider);
          });
        },
      ),
    );
  }

  Future<void> _editProvider(ApiProviderModel provider) async {
    await showDialog(
      context: context,
      builder: (context) => EditProviderDialog(
        provider: provider,
        onProviderUpdated: (updatedProvider) {
          setState(() {
            final index = _providers.indexWhere((p) => p.id == updatedProvider.id);
            if (index >= 0) {
              _providers[index] = updatedProvider;
            }
          });
        },
      ),
    );
  }

  Future<void> _deleteProvider(ApiProviderModel provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Provider'),
        content: Text('Are you sure you want to delete "${provider.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _providerService.deleteProvider(provider.id);
        setState(() {
          _providers.removeWhere((p) => p.id == provider.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete provider: $e')),
        );
      }
    }
  }

  Future<void> _testProvider(ApiProviderModel provider) async {
    try {
      final success = await _providerService.testProvider(provider.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Provider test successful!' : 'Provider test failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Provider test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Providers'),
        actions: [
          IconButton(
            onPressed: _showAddProviderDialog,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProviders,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _providers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.api, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No API providers configured',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first provider to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _showAddProviderDialog,
                            child: Text('Add Provider'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProviders,
                      child: ListView.builder(
                        itemCount: _providers.length,
                        itemBuilder: (context, index) {
                          final provider = _providers[index];
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: provider.isActive ? Colors.green : Colors.grey,
                                child: Icon(
                                  Icons.api,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(provider.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.baseUrl),
                                  if (provider.model != null)
                                    Text('Model: ${provider.model}'),
                                  Text(
                                    provider.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: provider.isActive ? Colors.green : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _editProvider(provider);
                                      break;
                                    case 'test':
                                      _testProvider(provider);
                                      break;
                                    case 'delete':
                                      _deleteProvider(provider);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'test',
                                    child: ListTile(
                                      leading: Icon(Icons.science),
                                      title: Text('Test'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete, color: Colors.red),
                                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class AddProviderDialog extends StatefulWidget {
  final Function(ApiProviderModel) onProviderAdded;

  const AddProviderDialog({super.key, required this.onProviderAdded});

  @override
  State<AddProviderDialog> createState() => _AddProviderDialogState();
}

class _AddProviderDialogState extends State<AddProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProviderService _providerService = ProviderService();
  
  String _selectedTemplate = 'generic';
  final _nameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateFieldsFromTemplate();
  }

  void _updateFieldsFromTemplate() {
    final template = ProviderTemplates.templates[_selectedTemplate];
    if (template != null) {
      _nameController.text = template['name'] ?? '';
      _baseUrlController.text = template['baseUrl'] ?? '';
      _modelController.text = template['model'] ?? '';
    }
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure user is authenticated before calling backend
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null || session.accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before adding a provider.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = await _providerService.createFromTemplate(
        _selectedTemplate,
        _apiKeyController.text.trim(),
        name: _nameController.text.trim(),
        model: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
      );
      
      widget.onProviderAdded(provider);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add provider: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add API Provider'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedTemplate,
                decoration: InputDecoration(labelText: 'Template'),
                items: ProviderTemplates.templates.keys.map((key) {
                  return DropdownMenuItem(
                    value: key,
                    child: Text(ProviderTemplates.templates[key]!['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTemplate = value!;
                    _updateFieldsFromTemplate();
                  });
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value?.trim().isEmpty == true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _baseUrlController,
                decoration: InputDecoration(labelText: 'Base URL'),
                validator: (value) => value?.trim().isEmpty == true ? 'Base URL is required' : null,
              ),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(labelText: 'API Key'),
                obscureText: true,
                validator: (value) => value?.trim().isEmpty == true ? 'API Key is required' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: 'Model (optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProvider,
          child: _isLoading ? CircularProgressIndicator() : Text('Add'),
        ),
      ],
    );
  }
}

class EditProviderDialog extends StatefulWidget {
  final ApiProviderModel provider;
  final Function(ApiProviderModel) onProviderUpdated;

  const EditProviderDialog({
    super.key, 
    required this.provider, 
    required this.onProviderUpdated
  });

  @override
  State<EditProviderDialog> createState() => _EditProviderDialogState();
}

class _EditProviderDialogState extends State<EditProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProviderService _providerService = ProviderService();
  
  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.name);
    _apiKeyController = TextEditingController(text: widget.provider.apiKey);
    _modelController = TextEditingController(text: widget.provider.model ?? '');
    _isActive = widget.provider.isActive;
  }

  Future<void> _updateProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProvider = await _providerService.updateProvider(
        widget.provider.id,
        {
          'name': _nameController.text.trim(),
          'apiKey': _apiKeyController.text.trim(),
          'model': _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
          'isActive': _isActive,
        },
      );
      
      widget.onProviderUpdated(updatedProvider);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Provider updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update provider: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit API Provider'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value?.trim().isEmpty == true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(labelText: 'API Key'),
                obscureText: true,
                validator: (value) => value?.trim().isEmpty == true ? 'API Key is required' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: 'Model (optional)'),
              ),
              SwitchListTile(
                title: Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateProvider,
          child: _isLoading ? CircularProgressIndicator() : Text('Update'),
        ),
      ],
    );
  }
}
