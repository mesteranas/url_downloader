import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'settings.dart';
import 'package:flutter/widgets.dart';

import 'language.dart';
import 'package:http/http.dart' as http;
import 'viewText.dart';
import 'app.dart';
import 'contectUs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Language.runTranslation();
  runApp(test());
}
class test extends StatefulWidget{
  const test({Key?key}):super(key:key);
  @override
  State<test> createState()=>_test();
}
class _test extends State<test>{
  TextEditingController URL=TextEditingController();
  var _=Language.translate;
  _test();
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      locale: Locale(Language.languageCode),
      title: App.name,
      themeMode: ThemeMode.system,
      home:Builder(builder:(context) 
    =>Scaffold(
      appBar:AppBar(
        title: const Text(App.name),), 
        drawer: Drawer(
          child:ListView(children: [
          DrawerHeader(child: Text(_("navigation menu"))),
          ListTile(title:Text(_("settings")) ,onTap:() async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) =>SettingsDialog(this._) ));
            setState(() {
              
            });
          } ,),
          ListTile(title: Text(_("contect us")),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ContectUsDialog(this._)));
          },),
          ListTile(title: Text(_("donate")),onTap: (){
            launch("https://www.paypal.me/AMohammed231");
          },),
  ListTile(title: Text(_("visite project on github")),onTap: (){
    launch("https://github.com/mesteranas/"+App.appName);
  },),
  ListTile(title: Text(_("license")),onTap: ()async{
    String result;
    try{
    http.Response r=await http.get(Uri.parse("https://raw.githubusercontent.com/mesteranas/" + App.appName + "/main/LICENSE"));
    if ((r.statusCode==200)) {
      result=r.body;
    }else{
      result=_("error");
    }
    }catch(error){
      result=_("error");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewText(_("license"), result)));
  },),
  ListTile(title: Text(_("about")),onTap: (){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(title: Text(_("about")+" "+App.name),content:Center(child:Column(children: [
        ListTile(title: Text(_("version: ") + App.version.toString())),
        ListTile(title:Text(_("developer:")+" mesteranas")),
        ListTile(title:Text(_("description:") + App.description))
      ],) ,));
    });
  },)
        ],) ,),
        body:Container(alignment: Alignment.center
        ,child: Column(children: [
          TextFormField(controller: URL,decoration: InputDecoration(labelText: _("URL")),),
          ElevatedButton(onPressed: () async{
                        var path=await FilePicker.platform.getDirectoryPath();
            if(path!=""){
              Map<String, dynamic> infos={"url":URL.text,"title":URL.text.split("/").last,"path":path??""};
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DownloadVideo(infos: infos)));
            }

          }, child: Text(_("download")))
    ])),)));
  }
}
class DownloadVideo extends StatefulWidget {
  final Map<String, dynamic> infos;
  
  DownloadVideo({Key? key, required this.infos}) : super(key: key);
  
  @override
  State<DownloadVideo> createState() => _DownloadVideoState();
}

class _DownloadVideoState extends State<DownloadVideo> {
  var _ = Language.translate;
  bool error = false;
  double progress = 0.0;
  bool downloaded = false;

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  Future<void> startDownloading() async {
    try {
      var res = await http.Client().send(http.Request("GET", Uri.parse(widget.infos["url"])));
      var contentLength = res.contentLength ?? 0;
      var path = widget.infos["path"] + "/" + widget.infos["title"];
      var file = File(path);
      List<int> bytes = [];
      int downloadedBytes = 0;

      res.stream.listen((newBytes) {
        bytes.addAll(newBytes);
        downloadedBytes += newBytes.length;
        setState(() {
          progress = downloadedBytes / contentLength;
        });
      }).onDone(() async {
        await file.writeAsBytes(bytes);
        setState(() {
          downloaded = true;
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_("downloading")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!downloaded && !error)
              LinearProgressIndicator(
                value: progress,
              )
            else if (error)
              Text(_("an error detected"))
            else
              Text(_("downloaded")),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(_("close")),
            ),
          ],
        ),
      ),
    );
  }
}

