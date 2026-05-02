import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Replace with your Back4App keys
  final keyApplicationId = '34bpnYImIehm4ijBZioxklCWrrqMiQns2P78518z';
  final keyClientKey = 'aUw85eWnCPGSzZXJTNvdjmR7Bu5haC7j5ujuEiqu';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager BaaS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        // Material Design Rounded Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: AuthScreen(),
    );
  }
}

// --- SHARED UI WIDGET: GRADIENT BACKGROUND ---
class GradientBackground extends StatelessWidget {
  final Widget child;
  GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade300,
            Colors.deepPurple.shade900,
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// --- AUTHENTICATION SCREEN ---
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  void authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (isLogin) {
      final user = ParseUser(email, password, email);
      var response = await user.login();
      if (response.success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TaskListScreen()));
      } else {
        showError(response.error!.message);
      }
    } else {
      final user = ParseUser(email, password, email);
      var response = await user.signUp();
      if (response.success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TaskListScreen()));
      } else {
        showError(response.error!.message);
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 100, color: Colors.white),
                SizedBox(height: 30),
                Text(
                  isLogin ? 'Welcome Back' : 'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: 'Student Email ID', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: authenticate,
                  child: Text(isLogin ? 'LOG IN' : 'REGISTER'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? 'Need an account? Register here' : 'Already have an account? Log in',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- TASK CRUD SCREEN ---
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ParseObject> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('user', currentUser.toPointer())
      ..orderByDescending('createdAt'); // Show newest tasks first

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        tasks = response.results as List<ParseObject>;
        isLoading = false;
      });
    } else {
      setState(() {
        tasks = [];
        isLoading = false;
      });
    }
  }

  // BOTTOM SHEET FOR CREATE / UPDATE
  void showTaskBottomSheet({ParseObject? taskToEdit}) {
    final titleController = TextEditingController(text: taskToEdit?.get<String>('title') ?? '');
    final descController = TextEditingController(text: taskToEdit?.get<String>('description') ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Text(
                taskToEdit == null ? 'Create New Task' : 'Edit Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title', fillColor: Colors.grey.shade100),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description', fillColor: Colors.grey.shade100),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty) return;
                    
                    final currentUser = await ParseUser.currentUser() as ParseUser;
                    final task = taskToEdit ?? ParseObject('Task');
                    
                    task.set<String>('title', titleController.text);
                    task.set<String>('description', descController.text);
                    if (taskToEdit == null) {
                      task.set('user', currentUser.toPointer()); 
                    }

                    await task.save();
                    Navigator.pop(context);
                    fetchTasks(); 
                  },
                  child: Text('Save Task'),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // DELETE TASK
  Future<void> deleteTask(ParseObject task) async {
    await task.delete();
    fetchTasks();
  }

  // LOGOUT CONFIRMATION ALERT
  void confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // <-- Renamed to dialogContext
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out of your account?"),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(), // Use dialogContext
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                foregroundColor: Colors.white,
              ),
              child: Text("Log Out"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first using dialogContext
                
                final user = await ParseUser.currentUser() as ParseUser?;
                if (user != null) {
                  await user.logout();
                }

                // Safely check if the screen is still active before navigating
                if (!mounted) return; 
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: confirmLogout, // Calls the alert dialog
          ),
        ],
      ),
      body: GradientBackground(
        child: isLoading 
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : tasks.isEmpty
                ? Center(
                    child: Text('No tasks found. Tap + to add one!', 
                    style: TextStyle(color: Colors.white70, fontSize: 16)))
                : ListView.builder(
                    padding: EdgeInsets.only(top: 10, bottom: 80), // Padding for FAB
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key(task.objectId!),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          deleteTask(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Task deleted'), duration: Duration(seconds: 2))
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              task.get<String>('title') ?? 'No Title',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(task.get<String>('description') ?? 'No Description'),
                            ),
                            onTap: () => showTaskBottomSheet(taskToEdit: task), // Opens bottom sheet
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskBottomSheet(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        icon: Icon(Icons.add),
        label: Text('New Task'),
      ),
    );
  }
}