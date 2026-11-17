
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String selectedCategory = 'All';
  String searchQuery = '';
  int selectedIndex = 0;

  final Set<int> _favoriteIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesCategory = selectedCategory == 'All' ||
          product.category == selectedCategory;

      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    final products = productProvider.products;

    final categories = [
      'All',
      ...{
        for (final product in products) product.category,
      },
    ];

    final filteredProducts = _filterProducts(products);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFDCC7F3),
                    Color(0xFFF4C9D5),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Color(0xFF55415F),
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'fashion store',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          _GlassIconButton(
            icon: Icons.search_rounded,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              _searchController.selection = TextSelection.collapsed(
                offset: _searchController.text.length,
              );
            },
          ),
          const SizedBox(width: 5),
          Stack(
            children: [
              _GlassIconButton(
                icon: Icons.shopping_bag_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 2,
                  top: 1,
                  child: Container(
                    height: 18,
                    width: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0AFC1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF45313C),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : productProvider.error != null
              ? _buildError(productProvider.error!)
              : products.isEmpty
                  ? _buildEmpty()
                  : _buildHomeContent(
                      categories,
                      filteredProducts,
                    ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomeContent(
    List<String> categories,
    List<Product> filteredProducts,
  ) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () =>
          context.read<ProductProvider>().loadProducts(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),

                  const SizedBox(height: 28),

                  const Text(
                    'Find Your Style',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Discover pieces that express you.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildSearchBar(),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore Categories',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${categories.length} styles',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 43,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 9),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final selected =
                            selectedCategory == category;

                        final colors = [
                          const Color(0xFFE9DDF7),
                          const Color(0xFFFBE1E8),
                          const Color(0xFFDDF1E8),
                          const Color(0xFFFFEEC9),
                        ];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors[index % colors.length]
                                  : Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : AppTheme.border,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: colors[index % colors.length]
                                            .withValues(alpha: 0.45),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                if (selected) ...[
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 15,
                                    color: Color(0xFF66516E),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 27),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Our Collection',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lavender,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${filteredProducts.length} Products',
                          style: const TextStyle(
                            color: Color(0xFF675477),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          if (filteredProducts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No products found.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];
                    final favoriteId =
                        product.id ?? product.name.hashCode;

                    return ProductCard(
                      product: product,
                      isFavorite: _favoriteIds.contains(favoriteId),
                      onFavorite: () {
                        setState(() {
                          if (_favoriteIds.contains(favoriteId)) {
                            _favoriteIds.remove(favoriteId);
                          } else {
                            _favoriteIds.add(favoriteId);
                          }
                        });
                      },
                      onAddToCart: () =>
                          _addProductToCart(product),
                      onTap: () =>
                          _showProductDetails(product),
                    );
                  },
                  childCount: filteredProducts.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 17,
                  crossAxisSpacing: 13,
                  childAspectRatio: 0.62,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 205,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEADDF8),
            Color(0xFFF8DDE6),
            Color(0xFFFFEED8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8BFEA).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -45,
              child: _decorCircle(155, const Color(0xFFFFFFFF)),
            ),
            Positioned(
              right: 38,
              bottom: -60,
              child: _decorCircle(135, const Color(0xFFD9C7EF)),
            ),
            Positioned(
              right: 25,
              top: 40,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 65,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✦  NEW COLLECTION',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF755C83),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'STYLE THAT\nSPEAKS.',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      color: Color(0xFF493D50),
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Discover your next favourite look.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF776A7C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB9A6C9).withValues(alpha: 0.10),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search your favourite style...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF9C85AB),
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.shopping_bag_outlined, 'Cart'),
      (Icons.receipt_long_outlined, 'Orders'),
      (Icons.person_outline_rounded, 'About'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.95),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB9A6C9).withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: List.generate(items.length, (index) {
                  final selected = selectedIndex == index;

                  return Expanded(
                    child: InkWell(
                      onTap: () => _onNavigationTap(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.lavender
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                items[index].$1,
                                color: selected
                                    ? const Color(0xFF80639A)
                                    : AppTheme.textSecondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              items[index].$2,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: selected
                                    ? const Color(0xFF80639A)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNavigationTap(int index) {
    if (index == 0) {
      setState(() {
        selectedIndex = 0;
      });
      return;
    }

    final routes = [
      '/',
      '/cart',
      '/orders',
      '/about',
    ];

    Navigator.pushNamed(context, routes[index]);
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                context.read<ProductProvider>().loadProducts();
              },
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No products available.',
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Future<void> _addProductToCart(Product product) async {
    await context.read<CartProvider>().addToCart(product);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF80639A),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: ProductPhoto(
                        product: product,
                        height: 260,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: Color(0xFF957CA8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF957CA8),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context
                              .read<CartProvider>()
                              .addToCart(product);

                          if (!sheetContext.mounted) return;

                          Navigator.pop(sheetContext);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} added to cart',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                        ),
                        label: const Text('ADD TO CART'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.75),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF80639A),
                size: 21,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onTap,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: const Color(0xFFEDE5F0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBDA9CC).withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(21),
                      ),
                      child: ProductPhoto(
                        product: product,
                        width: double.infinity,
                      ),
                    ),
                  ),

                  if (product.isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE1E8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Color(0xFF9B526B),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 9,
                    right: 9,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 8,
                          sigmaY: 8,
                        ),
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.8),
                          child: InkWell(
                            onTap: onFavorite,
                            child: SizedBox(
                              height: 34,
                              width: 34,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: isFavorite
                                    ? const Color(0xFFE58FA9)
                                    : const Color(0xFF80639A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9B88A5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF82679A),
                          ),
                        ),
                      ),
                      Material(
                        color: const Color(0xFFE9DDF7),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onAddToCart,
                          customBorder: const CircleBorder(),
                          child: const SizedBox(
                            height: 34,
                            width: 34,
                            child: Icon(
                              Icons.add_rounded,
                              color: Color(0xFF705786),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductPhoto extends StatelessWidget {
  final Product product;
  final double? height;
  final double? width;

  const ProductPhoto({
    super.key,
    required this.product,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      product.image,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE9DDF7),
                Color(0xFFFBE5EA),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.checkroom_rounded,
              size: 58,
              color: Color(0xFF9B80B3),
            ),
          ),
        );
      },
    );
  }
}
