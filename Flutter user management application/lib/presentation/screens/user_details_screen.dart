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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  
  const UserDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(FetchUserDetails(userId: widget.userId));
  }
  
  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
  
  void _navigateToEditUser(User user) {
    context.goNamed(
      'edit-user',
      pathParameters: {'id': user.id.toString()},
      extra: user,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserDetailsLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditUser(state.user),
                );
              }
              return Container();
            },
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserDetailsLoading) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerUserDetails(),
            );
          } else if (state is UserDetailsLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User's name as title
                  Text(
                    user.name,
                    style: AppTheme.textTheme.displayMedium,
                  ),
                  
                  // Email
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.email,
                          style: AppTheme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  
                  // Phone
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        user.phone,
                        style: AppTheme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  
                  // Address
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.address,
                          style: AppTheme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  
                  // Company info if available
                  if (user.company != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Company',
                      style: AppTheme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.business, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.company!.name,
                            style: AppTheme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    
                    if (user.company!.catchPhrase != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Text(
                          '"${user.company!.catchPhrase}"',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                  
                  // Website if available
                  if (user.website != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Website',
                      style: AppTheme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchUrl(user.website!),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            user.website!,
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Geo location if available
                  if (user.geo != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Location',
                      style: AppTheme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.map, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Lat: ${user.geo!.lat}, Lng: ${user.geo!.lng}',
                          style: AppTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _buildMap(user.geo!),
                      ),
                    ),
                  ],
                  
                  // Action buttons
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Users'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToEditUser(user),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is UserDetailsError) {
            return ErrorRetryWidget(
              message: state.message,
              onRetry: () => context.read<UserBloc>().add(
                    FetchUserDetails(userId: widget.userId),
                  ),
            );
          }
          
          return Container();
        },
      ),
    );
  }
  
  Widget _buildMap(Geo geo) {
    try {
      final lat = double.parse(geo.lat);
      final lng = double.parse(geo.lng);
      final location = LatLng(lat, lng);
      
      return FlutterMap(
        options: MapOptions(
          // initialCenter: location,
          // initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location, // LatLng object
                width: 80,
                height: 80,
                builder: (context) => Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
            ],
          )
        ],
      );
    } catch (e) {
      // If there's an error parsing coordinates, show an error message
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'Unable to display map',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }
}