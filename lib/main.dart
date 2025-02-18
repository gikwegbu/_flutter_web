import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController imgCtrl = TextEditingController();
  String? imgUrl;
  bool dimBg = false;
  int _currentIndex = -1;

  late html.Document document;

  @override
  void initState() {
    document = html.window.document;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: (imgUrl != null)
                        ? GestureDetector(
                            onTap: _imgToggle,
                            child: HtmlWidget(
                              """
                                <div style="display: flex; flex-direction: row; align-items: center; justify-content: center;">
                                   <img src=$imgUrl />
                                </div>
                                    
                              """,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: imgCtrl,
                        decoration:
                            const InputDecoration(hintText: 'Image URL'),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s'))
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (imgCtrl.text.length < 5 ||
                            !imgCtrl.text.contains('http')) return;
                        setState(() {
                          imgUrl = imgCtrl.text;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _dimBgFnc(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: dimBg ? Colors.black.withOpacity(0.6) : null,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: PopupMenuButton<int>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 0,
              child: Text(
                "Enter fullscreen",
                style:
                    TextStyle(color: _currentIndex == 0 ? Colors.green : null),
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: Text(
                "Exit fullscreen",
                style:
                    TextStyle(color: _currentIndex == 1 ? Colors.green : null),
              ),
            ),
          ],
          onSelected: (val) => _onSelect(val),
          onOpened: () => _dimBgFnc(true),
          onCanceled: () => _dimBgFnc(false),
          offset: const Offset(0, 100),
          elevation: 2,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _dimBgFnc(bool status) {
    setState(() {
      dimBg = status;
    });
  }

  _imgToggle() {
    setState(() {
      _currentIndex = _currentIndex == 0 ? 1 : 0;
    });
    _fullscreenMode();
  }

  void _fullscreenMode() {
    if (kIsWeb) {
      _currentIndex == 0
          ? document.documentElement?.requestFullscreen()
          : document.exitFullscreen();
    } else {
      //mobile or desktop functionalities
    }
  }

  _onSelect(int val) {
    _dimBgFnc(false);
    if (_currentIndex == val) return;
    setState(() {
      _currentIndex = val;
    });
    _fullscreenMode();
  }

  @override
  void dispose() {
    super.dispose();
    // Disposing the controller to avoid memory leaks
    imgCtrl.dispose();
  }
}
