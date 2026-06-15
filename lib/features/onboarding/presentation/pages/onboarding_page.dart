import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.onFinish, super.key});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
                size: 56,
              ),
              const SizedBox(height: 24),
              Text(
                'HealTrack Daily',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A calm place to log meals, see daily nutrition, and find a short workout that fits your day.',
                style: textTheme.titleMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 32),
              _PreferenceRow(
                icon: Icons.restaurant,
                title: 'Health goal',
                value: 'Build steady daily habits',
              ),
              const SizedBox(height: 12),
              _PreferenceRow(
                icon: Icons.directions_walk,
                title: 'Activity level',
                value: 'Lightly active',
              ),
              const SizedBox(height: 12),
              _PreferenceRow(
                icon: Icons.event_available,
                title: 'Calendar',
                value: 'Connect later',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('getStartedButton'),
                  onPressed: onFinish,
                  child: const Text('Get Started'),
                ),
              ),
              TextButton(
                onPressed: onFinish,
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
