import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewsPage extends ConsumerStatefulWidget {
  final int productId;

  const ReviewsPage({super.key, required this.productId});

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  final List<Review> _reviews = [
    Review(
      author: 'John Doe',
      rating: 5,
      comment: 'Excellent product! Very satisfied with the quality.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      author: 'Jane Smith',
      rating: 4,
      comment: 'Good product, but shipping took a bit longer than expected.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and review')),
      );
      return;
    }

    setState(() {
      _reviews.insert(0, Review(
        author: 'You',
        rating: _rating.toInt(),
        comment: _reviewController.text,
        date: DateTime.now(),
      ));
    });

    _reviewController.clear();
    setState(() => _rating = 0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = _reviews.isEmpty
        ? 0.0
        : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Reviews'),
      ),
      body: Column(
        children: [
          _buildRatingSummary(averageRating),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ReviewCard(review: review);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReviewDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRatingSummary(double averageRating) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor()
                            ? Icons.star
                            : index < averageRating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_reviews.length} reviews',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              _buildRatingDistribution(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = _reviews.where((r) => r.rating == i).length;
    }

    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = distribution[rating] ?? 0;
        final percentage = _reviews.isEmpty ? 0.0 : (count / _reviews.length) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text('$rating'),
              const SizedBox(width: 8),
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$count'),
            ],
          ),
        );
      }),
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() => _rating = index + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class Review {
  final String author;
  final int rating;
  final String comment;
  final DateTime date;

  Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    review.author.isNotEmpty ? review.author[0].toUpperCase() : 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.author,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
