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
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager BaaS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthScreen(),
    );
  }
}

// --- AUTHENTICATION SCREEN ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

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
      // Registration: Using student email ID as requested
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Student Email ID'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: authenticate,
              child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Create an account' : 'Already have an account? Login'),
            )
          ],
        ),
      ),
    );
  }
}

// --- TASK CRUD SCREEN ---
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ParseObject> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // READ TASKS
  Future<void> fetchTasks() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('user', currentUser.toPointer());

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        tasks = response.results as List<ParseObject>;
      });
    } else {
      setState(() {
        tasks = [];
      });
    }
  }

  // CREATE / UPDATE TASK
  void showTaskDialog({ParseObject? taskToEdit}) {
    final titleController = TextEditingController(text: taskToEdit?.get<String>('title') ?? '');
    final descController = TextEditingController(text: taskToEdit?.get<String>('description') ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(taskToEdit == null ? 'New Task' : 'Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final currentUser = await ParseUser.currentUser() as ParseUser;
                final task = taskToEdit ?? ParseObject('Task');
                
                task.set<String>('title', titleController.text);
                task.set<String>('description', descController.text);
                if (taskToEdit == null) {
                  task.set('user', currentUser.toPointer()); // Link task to user
                }

                await task.save();
                Navigator.pop(context);
                fetchTasks(); // Refresh UI
              },
              child: Text('Save'),
            )
          ],
        );
      },
    );
  }

  // DELETE TASK
  Future<void> deleteTask(ParseObject task) async {
    await task.delete();
    fetchTasks();
  }

  // SECURE LOGOUT
  void logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks found. Create one!'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.get<String>('title') ?? 'No Title'),
                  subtitle: Text(task.get<String>('description') ?? 'No Description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showTaskDialog(taskToEdit: task),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}