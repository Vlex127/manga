import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  String language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181828),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181828),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle('ACCOUNT'),
          _buildAccountCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('APP SETTINGS'),
          _buildAppSettingsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('SUPPORT'),
          _buildSupportCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFB0B0C3),
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      color: const Color(0xFF23233A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/anya.png'), // Use your asset
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Logged in as @manga_reader',
                      style: TextStyle(
                        color: Color(0xFFB0B0C3),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: Color(0xFFB0B0C3), size: 18),
              ],
            ),
            const Divider(height: 32, color: Color(0xFF23233A)),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return Card(
      color: const Color(0xFF23233A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            value: notificationsEnabled,
            onChanged: (val) => setState(() => notificationsEnabled = val),
            title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 17)),
            activeColor: Colors.blueAccent,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
          _buildSettingsTile('Data Usage'),
          _buildSettingsTile('Reading Preferences'),
          _buildSettingsTile('Appearance'),
          ListTile(
            title: const Text('Language', style: TextStyle(color: Colors.white, fontSize: 17)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language, style: const TextStyle(color: Color(0xFFB0B0C3), fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFB0B0C3), size: 18),
              ],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 17)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFB0B0C3), size: 18),
      onTap: () {},
    );
  }

  Widget _buildSupportCard() {
    return Card(
      color: const Color(0xFF23233A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Help & Feedback', style: TextStyle(color: Colors.white, fontSize: 17)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFB0B0C3), size: 18),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About', style: TextStyle(color: Colors.white, fontSize: 17)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFB0B0C3), size: 18),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}