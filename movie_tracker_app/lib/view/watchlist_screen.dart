import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import '../../presenters/interactions/interactions_presenter.dart';
import '../../presenters/profile/profile_presenter.dart';
import '../../models/user_content/personal_list.dart';
import 'login_screen.dart';
import '../widgets/watchlist_card.dart';
import '../widgets/media_grid_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['در حال تماشا', 'تماشا شده', 'خواهم دید', 'علاقه‌مندی‌ها'];
  static const int _favoritesTabIndex = 3;
  // 🔹 فقط سه تب اول لیست شخصی واقعی هستن (تب چهارم = لایک‌ها)
  static const List<String> _defaultListNames = ['در حال تماشا', 'تماشا شده', 'خواهم دید'];

  bool _defaultListsEnsured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authPresenter = context.read<AuthPresenter>();
      if (authPresenter.authResponse?.user != null) {
        await _ensureDefaultLists();
        _fetchItemsForTab(_selectedTabIndex);
      }
    });
  }

  // 🔹 هسته‌ی اصلاح: مطمئن می‌شیم هر سه لیست پیش‌فرض وجود دارن؛ هرکدوم نبود، می‌سازیمش
  Future<void> _ensureDefaultLists() async {
    if (_defaultListsEnsured) return;
    final interactions = context.read<InteractionsPresenter>();

    await interactions.getUserLists();

    for (final name in _defaultListNames) {
      final exists = interactions.userLists.any((l) => l.name == name);
      if (!exists) {
        await interactions.createList(name);
      }
    }

    _defaultListsEnsured = true;
  }

  void _fetchItemsForTab(int tabIndex) {
    if (tabIndex == _favoritesTabIndex) {
      final profile = context.read<ProfilePresenter>();
      profile.getLikedMedia();
      return;
    }

    final interactions = context.read<InteractionsPresenter>();
    if (interactions.userLists.isEmpty) return;

    // 🔹 تطبیق بر اساس نام، نه ایندکس
    final tabName = _tabs[tabIndex];
    final matchingList = interactions.userLists.where((l) => l.name == tabName);
    if (matchingList.isEmpty) return;

    interactions.getListWithItems(matchingList.first.id);
  }

  void _onTabSelected(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
    });
    _fetchItemsForTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthPresenter>(
      builder: (context, authPresenter, _) {
        final user = authPresenter.authResponse?.user;

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
                  'برای مشاهده لیست تماشا وارد شوید',
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

        return Scaffold(
          backgroundColor: const Color(0xFF00161F),
          body: Consumer2<InteractionsPresenter, ProfilePresenter>(
            builder: (context, interactionsPresenter, profilePresenter, _) {
              final bool isFavoritesTab = _selectedTabIndex == _favoritesTabIndex;

              final selectedList = interactionsPresenter.selectedListWithItems;
              final List<PersonalListItemResponse> listItems = selectedList?.items ?? [];
              final likedMedia = profilePresenter.likedMedia;

              final int itemCount = isFavoritesTab ? likedMedia.length : listItems.length;
              final bool isLoading = isFavoritesTab
                  ? profilePresenter.isLoading
                  : interactionsPresenter.isLoading;

              return CustomScrollView(
                slivers: [
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
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
                                  onTap: () => _onTabSelected(idx),
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
                                      title,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مجموعه من',
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
                                    Text(
                                      _tabs[_selectedTabIndex],
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC7E7F8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '($itemCount)',
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
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF5AD9D9)),
                            ),
                          )
                        else if (itemCount == 0)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                isFavoritesTab
                                    ? 'هنوز چیزی لایک نکرده‌اید.'
                                    : 'هیچ آیتمی در این لیست یافت نشد.',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  color: Color(0xFFBCC9C8),
                                ),
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
                              return GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  mainAxisExtent: 360,
                                ),
                                itemCount: itemCount,
                                itemBuilder: (context, index) {
                                  if (isFavoritesTab) {
                                    return MediaGridCard(
                                      media: likedMedia[index],
                                      onTap: () {},
                                    );
                                  }
                                  return WatchlistCard(item: listItems[index]);
                                },
                              );
                            },
                          ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}