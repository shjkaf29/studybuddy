import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import 'add_task_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'study_timer_page.dart';
import 'progress_page.dart';
import 'attendance_page.dart';

class HomePage extends StatefulWidget {
  final String userEmail;

  const HomePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    final taskService = Provider.of<TaskService>(context, listen: false);
    setState(() {
      _tasksFuture = taskService.getTasks(userEmail: widget.userEmail);
    });
  }

  Widget _buildLogoPlaceholder({double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SB',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Update the _buildDrawer method

Widget _buildDrawer() {
  return Drawer(
    elevation: 16.0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoPlaceholder(size: 60),
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.userEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.task,
                  title: 'Tasks',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.timer,
                  title: 'Study Timer',
                  onTap: () => _navigateTo(const StudyTimerPage()),
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Progress',
                  onTap: () => _navigateTo(const ProgressPage()),
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: 'Attendance',
                  onTap: () => _navigateTo(const AttendancePage()),
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () => _navigateTo(
                    ProfilePage(userEmail: widget.userEmail),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _logout,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        color: color,
      ),
    ),
    onTap: onTap,
    dense: true,
    visualDensity: const VisualDensity(vertical: -1),
  );
}

void _navigateTo(Widget page) {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
  Future<void> _logout() async {
    Navigator.pop(context);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setBool('isLoggedIn', false);
        
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error logging out. Please try again.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Row(
          children: [
            _buildLogoPlaceholder(),
            const SizedBox(width: 8),
            const Text(
              'Study Buddy',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications coming soon!',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }
          
          final tasks = snapshot.data ?? [];
          
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tasks yet!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskPage(userEmail: widget.userEmail),
                        ),
                      );
                      if (result == true) {
                        _refreshTasks();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Your First Task',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => _refreshTasks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskCard(
                    task: task,
                    onToggleComplete: () async {
                      final taskService = Provider.of<TaskService>(context, listen: false);
                      await taskService.toggleTaskComplete(task.id);
                      _refreshTasks();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(userEmail: widget.userEmail),
            ),
          );
          if (result == true) {
            _refreshTasks();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}