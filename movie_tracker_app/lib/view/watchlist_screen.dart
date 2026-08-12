import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import '../../models/movie/watchlist_item.dart';
import 'login_screen.dart';
import '../widgets/watchlist_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Watching', 'Watched', 'Will watch', 'Favorites'];

  final List<WatchlistItem> _mockItems = [
    const WatchlistItem(
      title: 'The Azure Depths',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDZtZ5ONraXnCfUrs-ZFvo-DV-qgeiaq5SZCn8cqKoTIM2NNP0xXXZJaEth1NzxDbIUnjTRYt4-qPFQve2KOyFxk0xqg04bDjhmAtb6tYMEgCsfYqGkG3wpOU-pjOIYJaoemppfIcarMXLtzOCbV75GnTi6kHU5EwjyOPBe6VHqUiHNssWnYU1hvJt5rU92I-PJ3LJQxT4TwExe5uPoFyfQU-J8UWDHe-rxq55V4ntWwQFVA67gS-ieSA',
      subtitle: 'Season 3, Episode 4 • 85% Complete',
      progressLabel: 'New episodes in 2 days',
      progress: 0.85,
      status: WatchStatus.waitingNewEpisodes,
      tag: '4K ULTRA HD',
      isFavorite: true,
    ),
    const WatchlistItem(
      title: 'Echoes of Lavender',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDfnnBfe521Bwz7MSvZM04TaBKykwr4lsD0zWtvQ4qknTTP9PFcuDcf5ohEQd7BKjXqfbc3JPBTvInfklDGHH-8u_hcH1ShH-oxxU3e_oxz_OdUAUeLFvtWYjEaJuZDj2aCOehGIUvv-0D3P_DepOi6GFuB1ih93s6_R_VjnhQRpBsOLuMkaTAA29BYhHxbhxIv9uCqcMP08bb1igCTnTrNikZyYZhtuVCENcE57zz1JywivVgnJi6ZfQ',
      subtitle: 'Final Season • 100% Watched',
      progressLabel: 'Series Finale Watched',
      progress: 1.0,
      status: WatchStatus.completed,
      tag: 'Completed',
    ),
    const WatchlistItem(
      title: 'Neon Current',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDqlP5jqPNwGKwv1ijqez3oY3z5gBPlSGJ287m5uHuWMS2Oel9FnrFu5yGfB4QllgiqcMvxT5g7W_0PAOSn0Tnbi0dAeLi8NwB3cf0OlOiLhICr_Mx1H9c71h8JnFxvwaalivx2N-9Q5l3zXzyi4yB35j-rKZDscW8GsDDxPMbdUcQ2jMfuKdnDVcZuo5g2WJ_r2y7XibeUug6jP8Qr_D8N93WmMaGc220TTVd1J13OSlMeQ0emawxK5Q',
      subtitle: 'Season 1, Episode 2 • 12% Watched',
      progressLabel: 'Paused - Pick up where you left',
      progress: 0.12,
      status: WatchStatus.stopped,
    ),
    const WatchlistItem(
      title: 'Golden Horizon',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAtk_RQvOazZ15NsUPfPhZ16vg00lPRaEIXq_QazBm3kFWGB4gi4tpS_NoXSCLffRQEV6GVC4UzFfFBHiTD8h6FS9dPagfbozKpdpGC8F3aa9qgviGpeY-n4IGy23lgmul9_L5ivI9z9vjMNhGegxe3NJFZJ19I23EuOEJy-jJu2sRC51eR6yWAd1cgXsHOj97tsicF46AuTaWi1ztYURK_Wy1skuVAFCLcL5h3CaMs5kWzJRbSJ6dD_w',
      subtitle: 'Season 2 • 3 Episodes Left',
      progressLabel: 'Episodes available',
      progress: 0.65,
      status: WatchStatus.watching,
      isFavorite: true,
    ),
    const WatchlistItem(
      title: 'Bioluminescence',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBnl2-hBuTpb7DbJzK_6ebtBIdDsUz92DZY77aOrW_GSzEPAGQaW4prJzT0wl9FpomglitB5LEV1186-5t_jxIIvdIc_2xawsbpNMlukJZC9HUnjUU-ncKOuxuATaJ5R_3b4ByktFnjYBRBrUBH5cqL18IFAf5m_xM76iTNAndvpk2pJ41VqJziNTQzFbi6gfS2VXzmghpJFnkDcdftIFxgLrDIaVFwASYRwLhCed-cxNsQnBaMZ9imQ',
      subtitle: 'Series Premiere • New',
      progressLabel: 'Start Watching',
      progress: 0.0,
      status: WatchStatus.unwatched,
    ),
    const WatchlistItem(
      title: 'Velocity Zero',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBZ7R6IxQqN9O0JWIyHsWgyIBeXqRcGUK2CZiknZ9z8aPAk4f_bkju3Ww9sMrmyS727VIbji_GnnVSLFHk7x2kFnHPVv8q2xSoAJcIYpco7R8KoB2KG-6BJyXAHG8POMsm7RfecRSqxytern6wIO9VW4ZPY-MlQyI7Byrc19wMwzcQQyEEzSV53c-72zjDeyfiG57VggwCgHT0DKBXdgkOg-HQYUFSC0spfAD06CMrfxYFutn3S9M6bFw',
      subtitle: 'Season 4 • Episode 12',
      progressLabel: 'Season finale next week',
      progress: 0.92,
      status: WatchStatus.waitingNewEpisodes,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthPresenter>(
      builder: (context, presenter, _) {
        final user = presenter.authResponse?.user;

        // GUEST VIEW (Same logic as profile)
        if (user == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF00161F),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF08DA5),
                  foregroundColor: const Color(0xFF3F0018),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Log In to View Watchlist',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        // LOGGED IN USER VIEW
        return Scaffold(
          backgroundColor: const Color(0xFF00161F),
          body: CustomScrollView(
            slivers: [
              // Top App Bar
              SliverAppBar(
                backgroundColor: const Color(0xFF00161F).withOpacity(0.6),
                pinned: true,
                centerTitle: true,
                title: const Text(
                  'TV Time',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: Color(0xFF5AD9D9),
                  ),
                ),
              ),
              // Body Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final title = entry.value;
                          final isSelected = idx == _selectedTabIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: InkWell(
                              onTap: () => setState(() => _selectedTabIndex = idx),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF29B5B5).withOpacity(0.2) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF5AD9D9).withOpacity(0.3) : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF5AD9D9).withOpacity(0.1),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  title.toLowerCase(), // UI matches "will watch"
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF5AD9D9) : const Color(0xFFBCC9C8).withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MY COLLECTION',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: const Color(0xFFBCC9C8).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'Watchlist',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC7E7F8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${_mockItems.length})',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5AD9D9).withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C2E3B).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Color(0xFF5AD9D9),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Grid or List of items
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
                        // For a real grid that matches HTML flex flow better
                        // But ListView with fixed height cards might be easier. Wait, the HTML uses a grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3
                        // So GridView is appropriate. But items have fixed height children, so let's use GridView.builder
                        
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 360, // Fixed height for each card to prevent overflow
                          ),
                          itemCount: _mockItems.length,
                          itemBuilder: (context, index) {
                            return WatchlistCard(item: _mockItems[index]);
                          },
                        );
                      }
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
