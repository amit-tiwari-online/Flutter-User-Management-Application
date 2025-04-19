import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_management/bloc/user_event.dart';
import 'package:flutter_user_management/bloc/user_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_user_management/bloc/user_bloc.dart';
import 'package:flutter_user_management/presentation/widgets/user_list_item.dart';
import 'package:flutter_user_management/presentation/widgets/error_retry_widget.dart';
import 'package:flutter_user_management/presentation/widgets/shimmer_loading.dart';
import 'package:flutter_user_management/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isNearBottom) {
      context.read<UserBloc>().add(const LoadMoreUsers());
    }
  }
  
  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when within 200 pixels of the bottom
    return currentScroll >= (maxScroll - 200);
  }
  
  void _onSearch(String query) {
    if (query.isEmpty) {
      if (_isSearching) {
        setState(() {
          _isSearching = false;
        });
        context.read<UserBloc>().add(const ClearSearch());
      }
    } else {
      setState(() {
        _isSearching = true;
      });
      context.read<UserBloc>().add(SearchUsers(query: query));
    }
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
    });
    context.read<UserBloc>().add(const ClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(
                  bloc: context.read<UserBloc>(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserListLoading) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const ShimmerUserListItem(),
            );
          } else if (state is UserListLoaded) {
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                
                // User list
                Expanded(
                  child: state.users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isSearching
                                    ? 'No users found matching "${_searchController.text}"'
                                    : 'No users found',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              if (_isSearching) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _clearSearch,
                                  child: const Text('Clear Search'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (_isSearching) {
                              context.read<UserBloc>().add(
                                    SearchUsers(query: _searchController.text),
                                  );
                            } else {
                              context.read<UserBloc>().add(
                                    const FetchUserList(page: 1),
                                  );
                            }
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: state.users.length + 
                                (state.hasReachedMax ? 0 : 1), // +1 for loading indicator
                            itemBuilder: (context, index) {
                              if (index >= state.users.length) {
                                // Loading indicator at the bottom
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              final user = state.users[index];
                              return UserListItem(user: user);
                            },
                          ),
                        ),
                ),
              ],
            );
          } else if (state is UserListError) {
            return ErrorRetryWidget(
              message: state.message,
              onRetry: () => context.read<UserBloc>().add(
                    const FetchUserList(page: 1),
                  ),
            );
          } else if (state is UserLoadingMore) {
            // Show the current list with a loading indicator at the bottom
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.currentUsers.length + 1, // +1 for loading indicator
              itemBuilder: (context, index) {
                if (index >= state.currentUsers.length) {
                  // Loading indicator at the bottom
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final user = state.currentUsers[index];
                return UserListItem(user: user);
              },
            );
          }
          
          // For other states, show an empty container
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('add-user'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final UserBloc bloc;
  
  UserSearchDelegate({required this.bloc});
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
        // Clear the search when closing
        bloc.add(const ClearSearch());
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      bloc.add(const ClearSearch());
      return const Center(
        child: Text('Type to search users'),
      );
    }
    
    bloc.add(SearchUsers(query: query));
    
    return BlocBuilder<UserBloc, UserState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is UserListLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerUserListItem(),
          );
        } else if (state is UserListLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found matching "$query"',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return UserListItem(
                user: user,
                onTap: () {
                  close(context, user.id.toString());
                  context.goNamed(
                    'user-details',
                    pathParameters: {'id': user.id.toString()},
                  );
                },
              );
            },
          );
        } else if (state is UserListError) {
          return ErrorRetryWidget(
            message: state.message,
            onRetry: () => bloc.add(SearchUsers(query: query)),
          );
        }
        
        return Container();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    
    // For simplicity, we'll just show the results directly
    return buildResults(context);
  }
}