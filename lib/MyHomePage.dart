import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Define App ID and Token
const APP_ID = '8cf58d81ec414db0b14f857298a8ee6c';
const Token =
    '0068cf58d81ec414db0b14f857298a8ee6cIAB3WL647gZxWeWjh3IZ4xc7NvldhDBpkyqghlXrxkp6egx+f9gAAAAAEADbqsx0eZoCYgEAAQB5mgJi';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Init the app
  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone].request();

    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(APP_ID);
    var engine = await RtcEngine.createWithContext(context);
    // Define event handling logic

    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess ${channel} ${uid}');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
      });
    }));
    // Enable video
    await engine.enableVideo();
    // Join channel with channel name as 123
    await engine.joinChannel(Token, 'test', null, 0);

  }

  //Disconnect call
  Future<void> disconnect() async{
    _switch = false;
    RtcEngineContext context = RtcEngineContext(APP_ID);
    var engine = await RtcEngine.createWithContext(context);
    //engine.disableVideo();
    engine.leaveChannel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home '),
        ),
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _switch = !_switch;
                    });
                  },
                  child: Center(
                    child:
                        _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                   onPressed: () {
                     setState(() {
                       disconnect();
                     });
                   }, icon: const Icon(
                  Icons.call_end,
                  size: 60,
                  color: Colors.red,
                ),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return const Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: "test",
      );
    } else {
      return const Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}
