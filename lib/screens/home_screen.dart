
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
      appBar: AppBar(
        title: const Text(
          'FASHION STORE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 19,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.error != null
              ? _buildError(productProvider.error!)
              : products.isEmpty
                  ? _buildEmpty()
                  : _buildHomeContent(
                      categories,
                      filteredProducts,
                    ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/cart');
              break;
            case 2:
              Navigator.pushNamed(context, '/orders');
              break;
            case 3:
              Navigator.pushNamed(context, '/about');
              break;
          }

          if (index != 0) {
            setState(() {
              selectedIndex = 0;
            });
          }
        },
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(
    List<String> categories,
    List<Product> filteredProducts,
  ) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<ProductProvider>().loadProducts(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),

                  const SizedBox(height: 24),

                  const Text(
                    'Find Your Style',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Discover the latest fashion collection.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final selected =
                            selectedCategory == category;

                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.beige,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.black
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Our Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${filteredProducts.length} Products',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];

                    return ProductCard(
                      product: product,
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
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 175,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.beige,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'NEW COLLECTION',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'STYLE THAT\nSPEAKS.',
            style: TextStyle(
              fontSize: 29,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore our latest collection',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
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
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ProductPhoto(
                    product: product,
                    height: 250,
                    width: double.infinity,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  product.category,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

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
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                    ),
                    label: const Text('ADD TO CART'),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: ProductPhoto(
                      product: product,
                      width: double.infinity,
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primary,
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 19,
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
          color: AppTheme.beige,
          child: const Center(
            child: Icon(
              Icons.checkroom_outlined,
              size: 55,
              color: AppTheme.secondary,
            ),
          ),
        );
      },
    );
  }
}
