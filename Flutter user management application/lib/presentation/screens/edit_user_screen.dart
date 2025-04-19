import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_management/bloc/user_event.dart';
import 'package:flutter_user_management/bloc/user_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_user_management/bloc/user_bloc.dart';
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/presentation/widgets/error_retry_widget.dart';
import 'package:flutter_user_management/presentation/widgets/shimmer_loading.dart';
import 'package:flutter_user_management/utils/app_theme.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;
  final User? initialUser;
  
  const EditUserScreen({
    super.key,
    required this.userId,
    this.initialUser,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  bool _isLoading = false;
  bool _formDirty = false;
  User? _user;
  
  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    
    // If initialUser is provided, use it
    if (widget.initialUser != null) {
      _user = widget.initialUser;
      _initializeControllers();
    } else {
      // Otherwise, fetch user data
      context.read<UserBloc>().add(FetchUserDetails(userId: widget.userId));
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  void _initializeControllers() {
    if (_user != null) {
      _nameController.text = _user!.name;
      _emailController.text = _user!.email;
      _phoneController.text = _user!.phone;
      _addressController.text = _user!.address;
    }
  }
  
  void _onUserLoaded(User user) {
    setState(() {
      _user = user;
      _initializeControllers();
    });
  }
  
  void _updateFormDirty() {
    if (_user != null) {
      final isDirty = _nameController.text != _user!.name ||
                     _emailController.text != _user!.email ||
                     _phoneController.text != _user!.phone ||
                     _addressController.text != _user!.address;
      
      setState(() {
        _formDirty = isDirty;
      });
    }
  }
  
  Future<void> _updateUser() async {
    if (_user == null || !_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final updatedUser = _user!.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    
    context.read<UserBloc>().add(UpdateUser(user: updatedUser));
  }
  
  void _onUpdateSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User updated successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    
    // Navigate back to user details
    context.goNamed(
      'user-details',
      pathParameters: {'id': widget.userId.toString()},
    );
  }
  
  void _onUpdateError(String message) {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
  
  Future<bool> _onWillPop() async {
    if (_formDirty) {
      // Show confirmation dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes that will be lost if you leave this page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('DISCARD'),
            ),
          ],
        ),
      );
      
      return result ?? false;
    }
    
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit User'),
        ),
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserDetailsLoaded) {
              _onUserLoaded(state.user);
            } else if (state is UserUpdateSuccess) {
              _onUpdateSuccess();
            } else if (state is UserUpdateError) {
              _onUpdateError(state.message);
            }
          },
          builder: (context, state) {
            if (state is UserDetailsLoading && _user == null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ShimmerUserDetails(),
              );
            } else if (state is UserDetailsError && _user == null) {
              return ErrorRetryWidget(
                message: state.message,
                onRetry: () => context.read<UserBloc>().add(
                      FetchUserDetails(userId: widget.userId),
                    ),
              );
            }
            
            // Show form if user is loaded or provided
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                onChanged: _updateFormDirty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter email address',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        hintText: 'Enter phone number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Address field
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                      maxLines: 2,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _onWillPop().then((canPop) {
                                      if (canPop) {
                                        context.pop();
                                      }
                                    }),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading || !_formDirty
                                ? null
                                : _updateUser,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
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