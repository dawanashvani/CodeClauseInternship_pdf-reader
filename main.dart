
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String assetPDFPath = "";
  String urlPDFPath = "";

  @override
  void initState() {
    super.initState();

    getFileFromAsset("assets/mypdf.pdf").then((f) {
      setState(() {
        assetPDFPath = f.path;
        print(assetPDFPath);
      });
    });

    getFileFromUrl("http://www.pdf995.com/samples/pdf.pdf").then((f) {
      setState(() {
        urlPDFPath = f.path;
        print(urlPDFPath);
      });
    });
  }

  Future<File> getFileFromAsset(String asset) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdf.pdf");

      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    } catch (e) {
      throw Exception("Error opening asset file");
    }
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter PDF Tutorial"),
        ),
        body: Center(
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Open from URL"),
                  onPressed: () {
                    if (urlPDFPath.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewPage(path: urlPDFPath),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  child: const Text("Open from Asset"),
                  onPressed: () {
                    if (assetPDFPath.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewPage(path: assetPDFPath),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key? key, required this.path}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  late PdfViewerController _pdfViewController;
  bool pdfReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Document"),
      ),
      body: Stack(
        children: <Widget>[
          SfPdfViewer.file(
            File(widget.path),
            controller: _pdfViewController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                pdfReady = true;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {});
            },
          ),
          if (!pdfReady)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_pdfViewController.pageNumber > 1)
            FloatingActionButton.extended(
              backgroundColor: Colors.red,
              label: Text("Go to ${_pdfViewController.pageNumber - 1}"),
              onPressed: () {
                setState(() {
                  _pdfViewController.jumpToPage(_pdfViewController.pageNumber - 1);
                });
              },
            ),
          if (_pdfViewController.pageNumber < _pdfViewController.pageCount)
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              label: Text("Go to ${_pdfViewController.pageNumber + 1}"),
              onPressed: () {
                setState(() {
                  _pdfViewController.jumpToPage(_pdfViewController.pageNumber + 1);
                });
              },
            ),
        ],
      ),
    );
  }
}
