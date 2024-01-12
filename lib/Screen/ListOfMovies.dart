import 'dart:convert';
import 'package:flutter/material.dart';
import '../API/CallApi.dart';
import '../Models/Movies.dart';
import 'AllListMovies.dart';

class ListOfMovies extends StatefulWidget {
  @override
  _ListOfMoviesState createState() => _ListOfMoviesState();
}

class _ListOfMoviesState extends State<ListOfMovies> {
  List<Movies> allMovies = [];
  List<Movies> favoriteMovies = [];
  Movies? selectedFavorite;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    List<Movies> movies = await getAllMovies();
    setState(() {
      allMovies = movies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Movies',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allMovies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: allMovies[index],
                    favoriteMovies: favoriteMovies,
                    onFavoriteChanged: () {
                      setState(() {
                        updateFavorites(allMovies[index]);
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Favorite Movies',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllMovies(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: favoriteMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: favoriteMovies[index],
                            favoriteMovies: favoriteMovies,
                            onFavoriteChanged: () {
                              setState(() {
                                updateFavorites(favoriteMovies[index]);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            selectedFavorite != null
                ? Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'Selected Favorite Movie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  MovieCard(movie: selectedFavorite!, favoriteMovies: [], onFavoriteChanged: () {}),
                ],
              ),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void updateFavorites(Movies movie) {
    if (favoriteMovies.contains(movie)) {
      favoriteMovies.remove(movie);
      selectedFavorite = null;
    } else {
      favoriteMovies.add(movie);
      selectedFavorite = movie;
    }
  }
}

class MovieCard extends StatefulWidget {
  final Movies movie;
  final List<Movies> favoriteMovies;
  final VoidCallback onFavoriteChanged;

  const MovieCard({
    required this.movie,
    required this.favoriteMovies,
    required this.onFavoriteChanged,
  });

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 2.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.movie.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: Icon(
                          widget.favoriteMovies.contains(widget.movie)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          widget.onFavoriteChanged();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Movies>> getAllMovies() async {
  List<Movies> allMovies = [];
  var response = await CallApi().getData('movie/popular?api_key=2bed19983257e2721e2538817c69683f');
  var jsonData = jsonDecode(response.body);
  var data = jsonData['results'];
  for (var item in data) {
    Movies movie = Movies(
      id: item['id'],
      name: item['title'],
      rating: (item['vote_average'] != null)
          ? (item['vote_average']! as num).toDouble()
          : 0.0,
      discription: item['overview'],
      date: item['release_date'],
      posterPath: item['poster_path'],
      originalLanguage: item['original_language'],
      favoriteMovies: item['favoriteMovies'],
      onFavoriteChanged: item['onFavoriteChanged'],
    );
    allMovies.add(movie);
  }
  return allMovies;
}
