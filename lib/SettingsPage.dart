import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MyAppData.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
// Class to display and edit league settings like name, quarter length, and timeouts
// Also shows invite code with copy button
class _SettingsPageState extends State<SettingsPage> {
  final _leagueNameController = TextEditingController();
  int _quarterLength = 12;
  int _timeoutsPerQuarter = 2;
  String _inviteCode = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = context.read<MyAppData>();
    final league = await data.getCurrentLeague();
    setState(() {
      _leagueNameController.text = league.name;
      _inviteCode = league.inviteCode;
      // assume you stored these in MyAppData or defaults
      _quarterLength = data.quarterLength;
      _timeoutsPerQuarter = data.timeouts;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final data = context.read<MyAppData>();
    await data.updateLeagueName(_leagueNameController.text);
    await data.updateGameSettings(_quarterLength, _timeoutsPerQuarter);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _leagueNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
            
                  Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  SizedBox(height: 24),

                  Text('League Name', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  TextField(
                    controller: _leagueNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
            
                  Text('Minutes per Quarter', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<int>(
                      isDense: true,
                      value: _quarterLength,
                      items: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16].map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
                      onChanged: (v) => setState(() => _quarterLength = v!),
                    ),
                  ),
                  SizedBox(height: 24),       

                  Text('Timeouts per Quarter', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<int>(
                      isDense: true,
                      value: _timeoutsPerQuarter,
                      items: [1, 2, 3, 4].map((t) => DropdownMenuItem(value: t, child: Text('$t'))).toList(),
                      onChanged: (v) => setState(() => _timeoutsPerQuarter = v!),
                    ),
                  ),
                  SizedBox(height: 34),
            
                  Row(
                    children: [
                      Expanded(child: Text('Invite Code: $_inviteCode', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      SizedBox(height: 4),
                      IconButton(
                        icon: Icon(Icons.copy),
                        iconSize: 26,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invite code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                  Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
