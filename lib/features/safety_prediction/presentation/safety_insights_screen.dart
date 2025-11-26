import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safepath/features/safety_prediction/cubit/safety_prediction_cubit.dart';
import 'package:safepath/ai/models/safety_prediction.dart';
import 'package:safepath/theme/colors.dart';

class SafetyInsightsScreen extends StatelessWidget {
  const SafetyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SafetyPredictionCubit()..loadPredictions(),
      child: const _SafetyInsightsView(),
    );
  }
}

class _SafetyInsightsView extends StatefulWidget {
  const _SafetyInsightsView();

  @override
  State<_SafetyInsightsView> createState() => _SafetyInsightsViewState();
}

class _SafetyInsightsViewState extends State<_SafetyInsightsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        title: const Text('AI Safety Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh predictions',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SafetyPredictionCubit>().loadPredictions();
            },
          ),
        ],
      ),
      body: BlocConsumer<SafetyPredictionCubit, SafetyPredictionState>(
        listener: (context, state) {
          if (state is SafetyPredictionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SafetyPredictionLoading ||
              state is SafetyPredictionInitial) {
            return const _LoadingView();
          }

          if (state is SafetyPredictionError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<SafetyPredictionCubit>()
                  .loadPredictions(demoMode: true),
            );
          }

          final predictions = (state as SafetyPredictionSuccess).predictions;
          return _PredictionsView(
            controller: _controller,
            predictions: predictions,
          );
        },
      ),
    );
  }
}

class _PredictionsView extends StatelessWidget {
  const _PredictionsView({
    required this.controller,
    required this.predictions,
  });

  final AnimationController controller;
  final List<SafetyPrediction> predictions;

  @override
  Widget build(BuildContext context) {
    final topPrediction = predictions.first;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<SafetyPredictionCubit>().loadPredictions(demoMode: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          _HeroCard(prediction: topPrediction),
          const SizedBox(height: 24),
          _MetricStrip(predictions: predictions),
          const SizedBox(height: 24),
          ...predictions
              .skip(1)
              .map(
                (prediction) => _PredictionCard(
                  prediction: prediction,
                  index: predictions.indexOf(prediction),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.prediction});

  final SafetyPrediction prediction;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [prediction.accentColor, prediction.accentColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: prediction.accentColor.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.areaName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    prediction.timeRange,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              _CircularScore(value: prediction.scorePercent),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Status: ${prediction.safetyLabel}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prediction.weatherImpact,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: prediction.recommendations
                .map(
                  (recommendation) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recommendation,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.predictions});

  final List<SafetyPrediction> predictions;

  @override
  Widget build(BuildContext context) {
    final avgScore = predictions
        .map((e) => e.predictedScore)
        .reduce((value, element) => value + element) /
        predictions.length;
    final avgConfidence = predictions
        .map((e) => e.confidence)
        .reduce((value, element) => value + element) /
        predictions.length;

    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            title: 'City Safety Index',
            value: '${(avgScore * 100).round()}%',
            icon: Icons.shield,
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            title: 'Model Confidence',
            value: '${(avgConfidence * 100).round()}%',
            icon: Icons.insights,
            gradient: const LinearGradient(
              colors: [Color(0xFF06D6A0), Color(0xFF4ADEDE)],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({
    required this.prediction,
    required this.index,
  });

  final SafetyPrediction prediction;
  final int index;

  @override
  Widget build(BuildContext context) {
    final animationDelay = 200 * index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, (1 - value) * 40),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: prediction.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prediction.areaName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                _ScoreChip(score: prediction.scorePercent),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Window • ${prediction.timeRange}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prediction.riskFactors
                  .map(
                    (factor) => Chip(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      label: Text(
                        factor,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularScore extends StatelessWidget {
  const _CircularScore({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 8,
            backgroundColor: Colors.white.withOpacity(0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'safety',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (score >= 75) {
      color = AppColors.safe;
    } else if (score >= 55) {
      color = AppColors.moderate;
    } else {
      color = AppColors.unsafe;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Calibrating AI model…',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            Text(
              'Unable to load predictions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

