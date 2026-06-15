import 'package:flutter/material.dart';

import '../../domain/entities/user_health_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.profile,
    required this.accountEmail,
    required this.loginStatus,
    required this.onLogout,
    super.key,
  });

  final UserHealthProfile profile;
  final String accountEmail;
  final String loginStatus;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeader(profile: profile),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.alternate_email,
              label: 'Account email',
              value: accountEmail,
            ),
            _InfoTile(
              icon: Icons.verified_user_outlined,
              label: 'Login status',
              value: loginStatus,
            ),
            _InfoTile(
              icon: Icons.badge_outlined,
              label: 'Age range',
              value: profile.ageRange,
            ),
            _InfoTile(
              icon: Icons.favorite_outline,
              label: 'Current body/status',
              value: profile.bodyStatus,
            ),
            _InfoTile(
              icon: Icons.flag_outlined,
              label: 'Health goal',
              value: profile.healthGoal,
            ),
            _InfoTile(
              icon: Icons.directions_walk,
              label: 'Activity level',
              value: profile.activityLevel,
            ),
            _InfoTile(
              icon: Icons.fitness_center,
              label: 'Workout level',
              value: profile.workoutLevel,
            ),
            _InfoTile(
              icon: Icons.restaurant,
              label: 'Food preferences',
              value: profile.foodPreferences.join(', '),
            ),
            _InfoTile(
              icon: Icons.no_food_outlined,
              label: 'Allergies / avoid list',
              value: profile.avoidList.join(', '),
            ),
            _InfoTile(
              icon: Icons.timer_outlined,
              label: 'Preferred workout duration',
              value: profile.preferredWorkoutDuration,
            ),
            _InfoTile(
              icon: Icons.home_repair_service_outlined,
              label: 'Available equipment',
              value: profile.availableEquipment.join(', '),
            ),
            _InfoTile(
              icon: Icons.calendar_month,
              label: 'Calendar connection',
              value: profile.calendarConnectionStatus,
            ),
            const SizedBox(height: 12),
            const _SafetyNote(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('logoutButton'),
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserHealthProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Text('H'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Health routines, balanced meals, and safe movement.',
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'HealTrack focuses on habits, energy, balanced meals, and movement. For younger users or weight-related goals, discuss plans with a trusted adult or qualified professional.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
