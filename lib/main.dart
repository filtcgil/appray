import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDxX17vw2ZRTFaaumfp16_FndG0X9HovH0",
      authDomain: "filt-ae054.firebaseapp.com",
      projectId: "filt-ae054",
      storageBucket: "filt-ae054.firebasestorage.app",
      messagingSenderId: "345664437296",
      appId: "1:345664437296:web:bf0531b4d99494b83681f5",
    ),
  );
  runApp(const FiltApp());
}

class FiltApp extends StatelessWidget {
  const FiltApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.red, useMaterial3: true),
      home: const WelcomePage(),
    );
  }
}

// --- WELCOME PAGE ---
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [Colors.red[900]!, Colors.red[700]!])
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.train, size: 80, color: Colors.white),
            const Text("FILT CGIL", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
              style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50), backgroundColor: Colors.white, foregroundColor: Colors.red[900]),
              child: const Text("ACCEDI"),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage())),
              style: OutlinedButton.styleFrom(minimumSize: const Size(250, 50), side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
              child: const Text("REGISTRATI"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REGISTRAZIONE ---
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController(), _cognome = TextEditingController(), 
  _email = TextEditingController(), _pass = TextEditingController(), _confirmPass = TextEditingController(),
  _telefono = TextEditingController(), _impianto = TextEditingController();

  String? _settore = 'Terra', _sottoSettore = 'Ferrovieri', _gruppo, _azienda, _divisione = 'Regionale';

  void _registra() async {
    if (_formKey.currentState!.validate() && _pass.text == _confirmPass.text) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text);
        await FirebaseFirestore.instance.collection('Utenti').doc(_email.text.trim().toLowerCase()).set({
          'uid': userCredential.user!.uid, 'nome': _nome.text, 'cognome': _cognome.text, 'email': _email.text.trim().toLowerCase(),
          'telefono': _telefono.text, 'settore': _settore, 'sottoSettore': _sottoSettore, 
          'gruppo': _gruppo, 'azienda': _azienda, 'divisione': _divisione,
          'impianto': _impianto.text, 'ruolo_app': 'utente'
        });
        Navigator.pop(context);
      } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e"))); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrazione")),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(children: [
        TextFormField(controller: _nome, decoration: const InputDecoration(labelText: "Nome")),
        TextFormField(controller: _cognome, decoration: const InputDecoration(labelText: "Cognome")),
        DropdownButtonFormField<String>(value: _settore, items: ['Aria', 'Mare', 'Terra'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _settore = v), decoration: const InputDecoration(labelText: "Settore")),
        if (_settore == 'Terra') DropdownButtonFormField<String>(value: _sottoSettore, items: ['Ferrovieri', 'TPL', 'Pompe Funebri', 'Impianti a fune'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _sottoSettore = v), decoration: const InputDecoration(labelText: "Sotto-Settore")),
        DropdownButtonFormField<String>(value: _gruppo, items: [const DropdownMenuItem(value: null, child: Text("Nessun Gruppo")), const DropdownMenuItem(value: "Gruppo FS", child: Text("Gruppo FS"))], onChanged: (v) => setState(() => _gruppo = v), decoration: const InputDecoration(labelText: "Gruppo")),
        DropdownButtonFormField<String>(value: _azienda, items: (_gruppo == 'Gruppo FS' ? ['Trenitalia', 'RFI', 'MERCITALIA'] : ['Italo', 'ArenaWay', 'SNCF', 'Trenord']).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _azienda = v), decoration: const InputDecoration(labelText: "Azienda")),
        DropdownButtonFormField<String>(value: _divisione, items: ['Regionale', 'Long Haul'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _divisione = v), decoration: const InputDecoration(labelText: "Divisione")),
        TextFormField(controller: _impianto, decoration: const InputDecoration(labelText: "Impianto")),
        TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
        TextFormField(controller: _pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
        TextFormField(controller: _confirmPass, decoration: const InputDecoration(labelText: "Conferma Password"), obscureText: true),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _registra, child: const Text("REGISTRATI")),
      ]))),
    );
  }
}

// --- LOGIN ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController(), _pass = TextEditingController();
  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text);
      var userDoc = await FirebaseFirestore.instance.collection('Utenti').doc(_email.text.trim().toLowerCase()).get();
      if (userDoc.exists) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigation(userData: userDoc.data()!)));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Credenziali errate"))); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Login")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
      TextField(controller: _pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _login, child: const Text("ENTRA")),
    ])));
  }
}

// --- NAVIGAZIONE ---
class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MainNavigation({super.key, required this.userData});
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: [
        ScioperiPage(userData: widget.userData),
        const NewsPage(),
        DrivePage(userData: widget.userData),
      ]),
      bottomNavigationBar: BottomNavigationBar(currentIndex: _index, onTap: (i) => setState(() => _index = i), items: const [
        BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: "Scioperi"),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
        BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: "Drive"),
      ]),
    );
  }
}

// --- SCIOPERI ---
class ScioperiPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ScioperiPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scioperi")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Scioperi').orderBy('Data_sciopero').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
              DateTime data = (d['Data_sciopero'] as Timestamp).toDate();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${data.day}/${data.month}/${data.year}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text("Azienda: ${d['Azienda'] ?? 'N.D.'}"),
                      if (d['Allegato_url'] != null)
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(url: d['Allegato_url'], name: "Allegato Sciopero"))),
                          child: const Text("VEDI ALLEGATO"),
                        )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// --- NEWS ---
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("News")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('News').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['Titolo'] ?? 'News'),
                  onTap: () async {
                    final url = Uri.parse(data['Url']);
                    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// --- DRIVE ---
class DrivePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? folderId, folderName;
  const DrivePage({super.key, required this.userData, this.folderId, this.folderName});
  @override
  _DrivePageState createState() => _DrivePageState();
}

class _DrivePageState extends State<DrivePage> {
  final String apiKey = "AIzaSyAISFL6BXeg0ZoWrZokAIwJnYlvKew_OEE", rootId = "132T5InVI5X12UR1cs_4oNs29ZBuYo9Iy";
  List files = []; bool isLoading = true;

  @override
  void initState() { super.initState(); _caricaFile(); }

  Future<void> _caricaFile() async {
    setState(() => isLoading = true);
    final targetId = widget.folderId ?? rootId;
    final url = 'https://www.googleapis.com/drive/v3/files?q="$targetId"+in+parents&key=$apiKey&fields=files(id,name,mimeType,webViewLink)';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var all = json.decode(res.body)['files'] as List;
        setState(() {
          if (widget.folderId == null) {
            files = all.where((f) {
              String n = f['name'].toString().toLowerCase();
              return n == 'biblioteca' || n == widget.userData['settore'].toString().toLowerCase();
            }).toList();
          } else {
            files = all;
          }
          isLoading = false;
        });
      }
    } catch (e) { setState(() => isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName ?? "Documenti")),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final f = files[index];
          bool isFolder = f['mimeType'] == 'application/vnd.google-apps.folder';
          return ListTile(
            leading: Icon(isFolder ? Icons.folder : Icons.picture_as_pdf, color: isFolder ? Colors.amber : Colors.red),
            title: Text(f['name']),
            onTap: () {
              if (isFolder) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DrivePage(userData: widget.userData, folderId: f['id'], folderName: f['name'])));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(url: f['webViewLink'], name: f['name'])));
              }
            },
          );
        },
      ),
    );
  }
}

// --- FILE VIEWER ---
class FileViewer extends StatelessWidget {
  final String url, name;
  const FileViewer({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final regExp = RegExp(r"(file/d/|id=)([a-zA-Z0-9_-]{25,})");
    final match = regExp.firstMatch(url);
    final String? fileId = match?.group(2);
    final String directUrl = "https://drive.google.com/uc?id=$fileId";

    return Scaffold(
      appBar: AppBar(title: Text(name), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: fileId == null 
        ? const Center(child: Text("Documento non disponibile")) 
        : SfPdfViewer.network(directUrl),
    );
  }
}
