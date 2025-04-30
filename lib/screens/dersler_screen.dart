import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const DerslerScreen());
}

class DerslerScreen extends StatelessWidget {
  const DerslerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarım Dersleri',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DerslerEkrani(),
    );
  }
}

class DerslerEkrani extends StatefulWidget {
  const DerslerEkrani({super.key});

  @override
  State<DerslerEkrani> createState() => _DerslerEkraniState();
}

class _DerslerEkraniState extends State<DerslerEkrani> {
  // Move data to a separate class or service in a real app
  final List<Map<String, String>> videolar = const [
    {
      'title': 'Organik Tarımın Temelleri',
      'description': 'Bu derste organik tarımın temel prensiplerini öğreneceksiniz.',
      'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
      'videoId': 'dQw4w9WgXcQ'
    },
    {
      'title': 'Toprak Analizi Nasıl Yapılır?',
      'description': 'Toprak analizi yapmanın adımlarını ve önemini anlatan kapsamlı bir ders.',
      'thumbnail': 'https://img.youtube.com/vi/tgbNymZ7vqY/0.jpg',
      'videoId': 'tgbNymZ7vqY'
    },
    {
      'title': 'Ekolojik Tarım Yöntemleri',
      'description': 'Sürdürülebilir ve ekolojik tarım uygulamaları hakkında bilgiler.',
      'thumbnail': 'https://img.youtube.com/vi/J8vz1D_L_OE/0.jpg',
      'videoId': 'J8vz1D_L_OE'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarım Dersleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              showSearch(
                context: context,
                delegate: DersArama(videolar: videolar),
              );
            },
          ),
        ],
      ),
      body: videolar.isEmpty 
          ? const Center(child: Text('Henüz ders bulunmamaktadır.'))
          : ListView.builder(
              itemCount: videolar.length,
              itemBuilder: (context, index) {
                final video = videolar[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoDetayEkrani(
                            videoId: video['videoId']!,
                            title: video['title']!,
                            description: video['description']!,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 90,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              video['thumbnail']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  video['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement functionality to add new videos or refresh content
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yeni içerikler yükleniyor...')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class VideoDetayEkrani extends StatefulWidget {
  final String videoId;
  final String title;
  final String description;

  const VideoDetayEkrani({
    super.key, 
    required this.videoId, 
    required this.title,
    required this.description,
  });

  @override
  State<VideoDetayEkrani> createState() => _VideoDetayEkraniState();
}

class _VideoDetayEkraniState extends State<VideoDetayEkrani> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        setState(() {
          _isFullScreen = false;
        });
      },
      onEnterFullScreen: () {
        setState(() {
          _isFullScreen = true;
        });
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.green,
        progressColors: const ProgressBarColors(
          playedColor: Colors.green,
          handleColor: Colors.greenAccent,
        ),
        onReady: () {
          // Ready callback
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: _isFullScreen ? null : AppBar(title: Text(widget.title)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.description),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildControls(),
                  ],
                ),
              ),
              // Notes section
              Expanded(
                child: _buildNotes(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Wrap(
      spacing: 10,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.bookmark_add),
          label: const Text('Kaydet'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ders kaydedildi')),
            );
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.share),
          label: const Text('Paylaş'),
          onPressed: () {
            // Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
            );
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('İndir'),
          onPressed: () {
            // Implement download functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('İndirme özelliği yakında eklenecek')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notlarım',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Ders hakkında notlarınızı buraya yazabilirsiniz...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DersArama extends SearchDelegate<String> {
  final List<Map<String, String>> videolar;

  DersArama({required this.videolar});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = videolar
        .where((video) =>
            video['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Ders aramak için yazın...'),
      );
    }

    final suggestions = videolar
        .where((video) =>
            video['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(context, suggestions);
  }

  Widget _buildSearchResults(BuildContext context, List<Map<String, String>> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final video = results[index];
        return ListTile(
          leading: SizedBox(
            width: 80,
            child: Image.network(
              video['thumbnail']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),
          title: Text(video['title']!),
          subtitle: Text(video['description'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoDetayEkrani(
                  videoId: video['videoId']!,
                  title: video['title']!,
                  description: video['description']!,
                ),
              ),
            );
            close(context, video['videoId']!);
          },
        );
      },
    );
  }
}


