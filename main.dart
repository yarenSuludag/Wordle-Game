import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('kullanici').doc(user.uid).update({
          'aktiflik': true
        });
        print("Aktiflik durumu güncellendi: true");
      } catch (e) {
        print("Aktiflik güncellenirken hata oluştu: $e");
      }
    } else {
      try {
        var snapshot = await FirebaseFirestore.instance.collection('kullanici').get();
        for (var doc in snapshot.docs) {
          await doc.reference.update({
            'aktiflik': false
          });
        }
        print("Tüm kullanıcılar pasifleştirildi");
      } catch (e) {
        print("Pasifleştirme işlemi sırasında hata oluştu: $e");
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _userId;  // Kullanıcı ID'sini saklamak için


  void _login() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final userQuery = await firestore
          .collection('kullanici')
          .where('isim', isEqualTo: _nameController.text)
          .where('sifre', isEqualTo: _passwordController.text)
          .get();

      if (userQuery.docs.isNotEmpty) {
        _userId = userQuery.docs.first.id;  // Kullanıcı ID'sini sakla
        await firestore.collection('kullanici').doc(_userId).update({
          'aktiflik': true
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        print('No user found');
      }
    } catch (e) {
      print('Error logging in: $e');
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Word Game'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              ElevatedButton(
                onPressed: _goToRegister,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('kullanici').add({
        'isim': _nameController.text,
        'sifre': _passwordController.text,
      });
      print('User registered successfully');
      Navigator.pop(context);
    } catch (e) {
      print('Error registering: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register to Word Game'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChannelSelectionPage(fixed: true)),
                );
              },
              child: const Text('Harf Sabiti Olan Kanallar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChannelSelectionPage(fixed: false)),
                );
              },
              child: const Text('Harf Sabiti Olmayan Kanallar'),
            ),
            const SizedBox(height: 20), // Aralık ekleyelim
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
class ChannelSelectionPage extends StatelessWidget {
  final bool fixed;
  const ChannelSelectionPage({Key? key, required this.fixed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sabit tanımlı değerleri dinamik olarak ayarlayalım
    String collectionBasePath = fixed ? 'sabitli' : 'sabitsiz';

    return Scaffold(
      appBar: AppBar(
        title: Text(fixed ? 'Harf Sabiti Olan Kanallar' : 'Harf Sabiti Olmayan Kanallar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigateToChannel(context, collectionBasePath, 'dort'),
              child: const Text('4 Harfli Kanallar'),
            ),
            ElevatedButton(
              onPressed: () => navigateToChannel(context, collectionBasePath, 'bes'),
              child: const Text('5 Harfli Kanallar'),
            ),
            ElevatedButton(
              onPressed: () => navigateToChannel(context, collectionBasePath, 'alti'),
              child: const Text('6 Harfli Kanallar'),
            ),
            ElevatedButton(
              onPressed: () => navigateToChannel(context, collectionBasePath, 'yedi'),
              child: const Text('7 Harfli Kanallar'),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToChannel(BuildContext context, String collectionPath, String subCollection) {
    // Yolu tam olarak oluşturalım: 'kelimekanal/sabitli/dort' gibi
    String fullPath = 'kelimekanal/$collectionPath/$subCollection';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChannelPage(collectionPath: fullPath)),
    );
  }
}


class ChannelPage extends StatelessWidget {
  final String collectionPath;

  const ChannelPage({Key? key, required this.collectionPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$collectionPath Kanalı'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kullanici')
            .where('aktiflik', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Bir hata oluştu: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var documents = snapshot.data?.docs ?? [];
          if (documents.isEmpty) {
            return const Text("Aktif kullanıcı yok.");
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var docData = documents[index].data() as Map<String, dynamic>;
              var userName = docData['isim'] ?? 'İsim yok';
              return ListTile(
                title: Text(userName),
                trailing: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendRequest(context, documents[index].id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRequests(context),
        child: Icon(Icons.notifications),
      ),
    );
  }

  void _showRequests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('kullanici')
              .where('esles', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Bir hata oluştu: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            var documents = snapshot.data?.docs ?? [];
            if (documents.isEmpty) {
              return const Text("Esleşme bulunamadı.");
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var docData = documents[index].data() as Map<String, dynamic>;
                var userName = docData['isim'] ?? 'İsim yok';
                return ListTile(
                  title: Text(userName),
                  trailing: ElevatedButton(
                    child: const Text('Oyunu Başlat'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GameplayScreen(roomName: 'Wordle Oyunu')
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }



  void _sendRequest(BuildContext context, String userId) {
    // Firestore üzerinden istek gönderme işlemi
    FirebaseFirestore.instance.collection('kullanici').doc(userId).update({
      'esles': true
    });
  }
}

class GameplayScreen extends StatefulWidget {
  final String roomName;

  GameplayScreen({required this.roomName});

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  String _enteredWord = '';
  String _targetWord = _generateRandomWord();
  List<String> _guessedWords = [];
  List<List<Color>> _guessBoxes = [];
  int _maxGuesses = 6;
  int _remainingGuesses = 6;
  int _guessTimeInSeconds = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.roomName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kelimeyi Tahmin Edin:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildTargetWord(),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Tahmininizi Girin'),
              onChanged: (value) {
                setState(() {
                  _enteredWord = value.toUpperCase();
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeGuess,
              child: Text('Tahmin Et'),
            ),
            SizedBox(height: 20),
            Text(
              'Tahminleriniz:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _guessedWords.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Text(
                          _guessedWords[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        _buildGuessBoxes(index),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Kalan Tahminler: $_remainingGuesses / $_maxGuesses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Kalan Süre: $_guessTimeInSeconds saniye',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _timer.cancel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      playerName: 'Sen',
                      playerCorrectGuesses: _guessedWords.where((word) => word == _targetWord).length,
                      playerIncorrectGuesses: _guessedWords.where((word) => word != _targetWord).length,
                      opponentName: 'Rakip',
                      opponentCorrectGuesses: 0,
                      opponentIncorrectGuesses: 0,
                      remainingSeconds: _guessTimeInSeconds,
                    ),
                  ),
                );
              },
              child: Text('Sonuçları Göster'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWord() {
    List<Widget> letters = [];
    for (int i = 0; i < _targetWord.length; i++) {
      letters.add(
        Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            _enteredWord.length > i ? _enteredWord[i] : '',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: letters,
    );
  }

  Widget _buildGuessBoxes(int index) {
    List<Widget> boxes = [];
    for (int i = 0; i < _targetWord.length; i++) {
      Color color = _guessBoxes[index][i];
      boxes.add(
        Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            _guessedWords[index][i],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return Row(
      children: boxes,
    );
  }

  void _makeGuess() {
    if (_isValidWord(_enteredWord) && !_guessedWords.contains(_enteredWord)) {
      List<Color> guessColors = _compareWords(_enteredWord);
      setState(() {
        _guessedWords.add(_enteredWord);
        _guessBoxes.add(guessColors);
        _remainingGuesses--;

        if (_targetWord == _enteredWord) {
          _showResultDialog('Tebrikler!', 'Doğru Tahmin! Kazandınız.');
        } else if (_remainingGuesses == 0) {
          _showResultDialog('Üzgünüz!', 'Tahmin Hakkınız Kalmadı. Kaybettiniz.');
        }
      });
    } else {
      _showErrorDialog();
    }
  }

  bool _isValidWord(String word) {
    return word.length >= 4 && word.length <= 7;
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text('Geçerli ve daha önce tahmin edilmemiş bir kelime girin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  List<Color> _compareWords(String guessedWord) {
    List<Color> colors = [];
    for (int i = 0; i < _targetWord.length; i++) {
      if (guessedWord.length > i && guessedWord[i] == _targetWord[i]) {
        colors.add(Colors.green); // Doğru yerdeki harf
      } else if (_targetWord.contains(guessedWord[i])) {
        colors.add(Colors.yellow); // Yanlış yerdeki harf
      } else {
        colors.add(Colors.grey); // Doğru harf yok
      }
    }
    return colors;
  }

  static String _generateRandomWord() {
    List<String> words = ['ASLAN', 'KALEM', 'ELMA', 'ATMACA', 'MANGO', 'KIWI', 'ASAL'];
    Random random = Random();
    return words[random.nextInt(words.length)];
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_guessTimeInSeconds > 0) {
          _guessTimeInSeconds--;
        } else {
          timer.cancel();
          _showResultDialog('Zaman Doldu!', 'Tahmin süresi doldu. Kaybettiniz.');
        }
      });
    });
  }
}


class ResultScreen extends StatelessWidget {
  final String playerName;
  final int playerCorrectGuesses;
  final int playerIncorrectGuesses;
  final String opponentName;
  final int opponentCorrectGuesses;
  final int opponentIncorrectGuesses;
  final int remainingSeconds;

  ResultScreen({
    required this.playerName,
    required this.playerCorrectGuesses,
    required this.playerIncorrectGuesses,
    required this.opponentName,
    required this.opponentCorrectGuesses,
    required this.opponentIncorrectGuesses,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    int playerScore = _calculateScore(playerCorrectGuesses, playerIncorrectGuesses, remainingSeconds);
    int opponentScore = _calculateScore(opponentCorrectGuesses, opponentIncorrectGuesses, remainingSeconds);

    String winner;
    if (playerScore > opponentScore) {
      winner = playerName;
    } else if (playerScore < opponentScore) {
      winner = opponentName;
    } else {
      winner = "Berabere";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Oyun Sonuçları'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sonuçlar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Senin Adın: $playerName',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Doğru Tahmin Sayısı: $playerCorrectGuesses',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Yanlış Tahmin Sayısı: $playerIncorrectGuesses',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Toplam Puan: $playerScore',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Rakibin Adı: $opponentName',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Doğru Tahmin Sayısı: $opponentCorrectGuesses',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Yanlış Tahmin Sayısı: $opponentIncorrectGuesses',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Toplam Puan: $opponentScore',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Kalan Saniye: $remainingSeconds',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Kazanan: $winner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/')); // Ana ekrana dön
              },
              child: Text('Ana Ekrana Dön'),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateScore(int correctGuesses, int incorrectGuesses, int remainingSeconds) {
    int correctGuessScore = correctGuesses * 10;
    int incorrectGuessScore = incorrectGuesses * 5;
    int timeBonus = remainingSeconds; // Her kalan saniye 1 puan olarak eklenir

    return correctGuessScore + incorrectGuessScore + timeBonus;
  }
}
