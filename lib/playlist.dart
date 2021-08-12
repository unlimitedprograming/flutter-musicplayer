import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/BGAudioPlayer/AudioPlayerTask.dart';
import 'package:musicplayer/BGAudioPlayer/Seekbar.dart';
import 'package:rxdart/rxdart.dart';

class Playlist extends StatefulWidget {
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    List<Map> tracks = [
      {
        'id': "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
        'album': "Science Friday",
        'title': "A Salute To Head-Scratching Science",
        'artist': "Science Friday and WNYC Studios",
        'artUri': "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
      },
      {
        'id': "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
        'album': "Science Friday",
        'title': "From Cat Rheology To Operatic Incompetence",
        'artist': "Science Friday and WNYC Studios",
        'artUri': "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
      }
    ];

    // List<MediaItem> _items = [];

    // for (int i = 0; i < tracks.length; i++) {
    //   Map track = tracks[i];

    //   _items.add(MediaItem(
    //     id: track['id'],
    //     album: track['album'],
    //     title: track['title'],
    //     artist: track['artist'],
    //     artUri: Uri.parse(track['artUrl']),
    //     extras: {
    //       'artUrl': track['artUrl']
    //     }
    //   ));
    // }

    // List<dynamic> list = [];
    // for (int i = 0; i < _items.length; i++) {
    //   var m = _items[i].toJson();
    //   print(m);
    //   list.add(m);
    // }
    var params = {"data": tracks};

    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Service Demo',
      // Enable this if you want the Android service to exit the foreground state on pause.
      // androidStopForegroundOnPause: false,
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
      params: params
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      // backgroundColor: Colors.black12,
      body: SingleChildScrollView(
        child: Column(
          children: [
 
            StreamBuilder<bool>(
              stream: AudioService.runningStream,
              builder: (context, snapshot) {
                
                if (snapshot.connectionState != ConnectionState.active) {
                  // Don't show anything until we've ascertained whether or not the
                  // service is running, since we want to show a different UI in
                  // each case.
                  return SizedBox();
                }
                // final running = snapshot.data ?? false;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (!running) ...[
                    //   // UI to show when we're not running, i.e. a menu.
                    //   audioPlayerButton(),
                      
                    // ] else ...[
                      // UI to show when we're running, i.e. player state/controls.

                      // Queue display/controls.
                      StreamBuilder<QueueState>(
                        stream: _queueStateStream,
                        builder: (context, snapshot) {
                          final queueState = snapshot.data;
                          final queue = queueState?.queue ?? [];
                          final mediaItem = queueState?.mediaItem;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (mediaItem != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                          Center(
                                            child: Image.network(
                                              mediaItem.artUri.toString(),
                                            )
                                          ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(mediaItem.title+' - '+mediaItem.artist,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    letterSpacing: 1,
                                                    color: Colors.black,
                                                  ),
                                            )
                                          ),
                                          
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.skip_previous),
                                                color: Colors.black,
                                                iconSize: 42.0,
                                                onPressed: mediaItem == queue.first
                                                    ? null
                                                    : AudioService.skipToPrevious,
                                              ),
                                              // Play/pause/stop buttons.
                                              StreamBuilder<PlaybackState>(
                                                stream: AudioService.playbackStateStream,
                                                builder: (context, snapshot) {
                                                  final playerState = snapshot.data;
                                                  final processingState = playerState?.processingState;
                                                  final playing = playerState?.playing ?? false;
                                                  
                                                  if (processingState == AudioProcessingState.connecting||
                                                          processingState == AudioProcessingState.buffering) {
                                                        return Container(
                                                          margin: EdgeInsets.all(8.0),
                                                          width: 42.0,
                                                          height: 42.0,
                                                          child: CircularProgressIndicator(),
                                                        );
                                                  }else
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        
                                                        if (playing) pauseButton() else playButton(),
                                                        // stopButton(),
                                                      ],
                                                    );
                                                },
                                              ),
                              
                                              IconButton(
                                                icon: Icon(Icons.skip_next),
                                                color: Colors.black,
                                                iconSize: 42.0,
                                                onPressed: mediaItem == queue.last
                                                    ? null
                                                    : AudioService.skipToNext,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    )
                                  ]
                                ),
                            ],
                          );
                        },
                      ),
                      
                      // A seek bar.
                      StreamBuilder<MediaState>(
                        stream: _mediaStateStream,
                        builder: (context, snapshot) {
                          final mediaState = snapshot.data;
                          if(mediaState != null && mediaState.mediaItem != null)

                            return SeekBar(
                              duration:
                                  mediaState?.mediaItem?.duration ?? Duration.zero,
                              position: mediaState?.position ?? Duration.zero,
                              onChangeEnd: (newPosition) {
                                AudioService.seekTo(newPosition);
                              },
                            );
                          else
                            return Container();
                        },
                      ),
                      
                      Container(
                        padding: EdgeInsets.fromLTRB(0,10,0,10),
                        height:MediaQuery.of(context).size.height*0.7,
                        child: StreamBuilder<QueueState>(
                          stream: _queueStateStream,
                          builder: (context, snapshot) {
                            final queueState = snapshot.data;
                            final queue = queueState?.queue ?? [];
                            final mediaItem = queueState?.mediaItem;
                            return ListView(
                              children: [
                                if (queue != null && queue.isNotEmpty)
                                  for (var i = 0; i < queue.length; i++)
                                    Container(
                                      key: ValueKey(queue[i]),
                                      child: Material(
                                        color: (mediaItem != null && mediaItem.id == queue[i].id)
                                            ? Theme.of(context).primaryColor
                                            : Colors.white,
                                        child: ListTile(
                                          title: Text(
                                            queue[i].title,
                                            style: TextStyle(
                                                color: (mediaItem != null && mediaItem.id == queue[i].id)
                                                    ? Colors.white
                                                    : Colors.black,
                                            )
                                          ),
                                          onTap: () {
                                            AudioService.customAction('updateMedia', queue[i].id);
                                          },
                                        ),
                                      ),
                                    ),
                              ],
                            );
                          },
                        ),
                      ), 

                    ],
                  // ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  
  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => MediaState(mediaItem, position));

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        color: Colors.black,
        iconSize: 42.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        color: Colors.black,
        iconSize: 42.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
