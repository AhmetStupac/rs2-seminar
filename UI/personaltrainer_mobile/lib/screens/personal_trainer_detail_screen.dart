import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/personal_trainer_rating.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_rating_provider.dart';
import 'package:personaltrainer_mobile/screens/purchase_options_screen.dart';
import 'package:personaltrainer_mobile/screens/training_session_booking_screen.dart';

class PersonalTrainerDetailScreen extends StatefulWidget {
  final PersonalTrainer trainer;

  const PersonalTrainerDetailScreen({super.key, required this.trainer});

  @override
  State<PersonalTrainerDetailScreen> createState() =>
      _PersonalTrainerDetailScreenState();
}

class _PersonalTrainerDetailScreenState
    extends State<PersonalTrainerDetailScreen> {
  final _ratingProvider = PersonalTrainerRatingProvider();
  final _commentController = TextEditingController();

  double _userRating = 0.0;
  PersonalTrainerRatingResponse? _myRating;
  PersonalTrainerRatingStats? _ratingStats;
  List<PersonalTrainerRatingResponse> _allRatings = [];
  bool _isLoadingRating = false;
  bool _showCommentField = false;

  @override
  void initState() {
    super.initState();
    _loadRatingData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadRatingData() async {
    if (widget.trainer.id == null) return;

    setState(() => _isLoadingRating = true);

    try {
      // Load user's own rating
      final myRating = await _ratingProvider.getMyRating(widget.trainer.id!);

      // Load rating statistics
      final stats = await _ratingProvider.getTrainerRatingStats(
        widget.trainer.id!,
      );

      // Load all ratings
      final allRatings = await _ratingProvider.getRatingsForTrainer(
        widget.trainer.id!,
      );

      setState(() {
        _myRating = myRating;
        _userRating = myRating?.rating?.toDouble() ?? 0.0;
        _commentController.text = myRating?.comment ?? '';
        _ratingStats = stats;
        _allRatings = allRatings;
        _isLoadingRating = false;
      });
    } catch (e) {
      print('Error loading rating data: $e');
      setState(() => _isLoadingRating = false);
    }
  }

  Future<void> _submitRating() async {
    if (widget.trainer.id == null || _userRating == 0) return;

    setState(() => _isLoadingRating = true);

    try {
      final request = PersonalTrainerRatingUpsertRequest(
        personalTrainerId: widget.trainer.id!,
        rating: _userRating.toInt(),
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (_myRating == null) {
        // Create new rating
        await _ratingProvider.createRating(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocjena uspješno dodana!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing rating
        await _ratingProvider.updateRating(_myRating!.id!, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocjena uspješno ažurirana!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Reload all rating data
      await _loadRatingData();
      setState(() => _showCommentField = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoadingRating = false);
    }
  }

  Future<void> _deleteRating() async {
    if (_myRating?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši ocjenu'),
        content: const Text(
          'Da li ste sigurni da želite obrisati vašu ocjenu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoadingRating = true);

    try {
      final success = await _ratingProvider.deleteRating(_myRating!.id!);

      if (success) {
        setState(() {
          _userRating = 0.0;
          _commentController.clear();
          _showCommentField = false;
        });

        // Reload all rating data
        await _loadRatingData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocjena uspješno obrisana!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška prilikom brisanja ocjene'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoadingRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button and name
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.trainer.userFirstName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // Balance the close button
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Profile Image
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        _getInitials(widget.trainer.userFirstName ?? ''),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Motto/Tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          const Text(
                            'Motiv:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.trainer.certifications ??
                                'Samo jako, nema lagano',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Contact Information
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Kontakt:', '000-000-000'),
                          _buildInfoRow('Grad:', 'Mostar'),
                          _buildInfoRow('Porijeklo:', 'BiH'),
                          _buildInfoRow('Spol:', 'Žensko'),
                          _buildInfoRow(
                            'Email:',
                            '${widget.trainer.userFirstName?.toLowerCase().replaceAll(' ', '.')}@gmail.com',
                          ),
                          if (widget.trainer.sport != null)
                            _buildInfoRow('Sport:', widget.trainer.sport!),
                          if (widget.trainer.yearsOfExperience != null)
                            _buildInfoRow(
                              'Iskustvo:',
                              '${widget.trainer.yearsOfExperience} godina',
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Rating Statistics
                    if (_ratingStats != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _ratingStats!.averageRating
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_ratingStats!.totalRatings} ocjena',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Rating Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Vaša ocjena',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_myRating != null && !_isLoadingRating)
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: _deleteRating,
                                  tooltip: 'Obriši ocjenu',
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_isLoadingRating)
                            const CircularProgressIndicator()
                          else
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _userRating = index + 1.0;
                                          _showCommentField = true;
                                        });
                                      },
                                      child: Icon(
                                        index < _userRating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 40,
                                        color: Colors.amber,
                                      ),
                                    );
                                  }),
                                ),

                                if (_userRating > 0) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Vaša ocjena: ${_userRating.toInt()}/5',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),

                                  if (_showCommentField) ...[
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _commentController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Dodajte komentar (opcionalno)',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                          12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _showCommentField = false;
                                              if (_myRating == null) {
                                                _userRating = 0.0;
                                                _commentController.clear();
                                              }
                                            });
                                          },
                                          child: const Text('Otkaži'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _submitRating,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            _myRating == null
                                                ? 'Dodaj ocjenu'
                                                : 'Ažuriraj',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // All Ratings List
                    if (_allRatings.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sve ocjene',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._allRatings.map(
                              (rating) => _buildRatingCard(rating),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Book Training Session Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TrainingSessionBookingScreen(
                                      trainer: widget.trainer,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today, size: 20),
                          label: const Text(
                            'Zakaži trening',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8B44A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Purchase Plans / Membership Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseOptionsScreen(
                                  trainer: widget.trainer,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                          label: const Text(
                            'Kupi plan / Članarinu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(PersonalTrainerRatingResponse rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rating.userName ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < (rating.rating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                rating.comment!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(rating.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
