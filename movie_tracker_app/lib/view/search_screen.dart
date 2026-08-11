import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../presenters/media/media_presenter.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/background_glows.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Name', 'Year', 'Director', 'Actor', 'Genre'];
  int _currentNavIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty) {
      context.read<MediaPresenter>().searchMedia(value);
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    // TODO: Handle bottom nav navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2D3A), // custom bg from HTML inline style
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: const Color(0xCC00161F), // surface/80
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'TV Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // headline-lg-mobile
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: -0.5, // tracking-tighter
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const BackgroundGlows(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x330F5F66), // glass-card equivalent bg
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by title...',
                        hintStyle: TextStyle(
                          color: const Color(0xFFBCC9C8).withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFFF08DA5) // coral-pink 
                                    : const Color(0xFF193846).withOpacity(0.4), // surface-variant/40
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFFF08DA5) 
                                      : Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: const Color(0xFFF08DA5).withOpacity(0.4),
                                    blurRadius: 10,
                                  )
                                ] : null,
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF00161F) : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent Searches / Results
                  Expanded(
                    child: Consumer<MediaPresenter>(
                      builder: (context, presenter, child) {
                        if (presenter.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFF08DA5)),
                          );
                        }
                        
                        if (_searchController.text.isEmpty) {
                          // Show Recent Searches Placeholder
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Searches',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color: Color(0xFFF08DA5),
                                        fontSize: 12,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // (Empty list placeholder)
                            ],
                          );
                        }

                        // Search Results Display
                        // As we don't have the exact MediaSearchResult structure, we just show a text for now.
                        return const Center(
                          child: Text(
                            'Search results will appear here...',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
