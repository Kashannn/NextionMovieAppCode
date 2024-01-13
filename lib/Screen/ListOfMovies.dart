import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get
import '../API/CallApi.dart';
import '../Models/Movies.dart';
import 'AllListMovies.dart';

class ListOfMovies extends StatefulWidget {
  @override
  _ListOfMoviesState createState() => _ListOfMoviesState();
}

class _ListOfMoviesState extends State<ListOfMovies> {
  final MovieController moviesController = Get.put(MovieController()); // Create an instance of MoviesController

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    List<Movies> movies = await getAllMovies();
    moviesController.setAllMovies(movies); // Use GetX controller to set allMovies
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
              child: Obx(
                    () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moviesController.allMovies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(
                      movie: moviesController.allMovies[index],
                      onFavoriteChanged: () {
                        moviesController.updateFavorites(moviesController.allMovies[index]);
                      },
                      moviesController: moviesController,

                    );
                  },
                ),
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
                              Get.to(AllMovies());
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
                      child: Obx(
                            () => ListView.builder(
                          itemCount: moviesController.favoriteMovies.length,
                          itemBuilder: (context, index) {
                            return MovieCard(
                              movie: moviesController.favoriteMovies[index],
                              onFavoriteChanged: () {
                                moviesController.updateFavorites(
                                    moviesController.favoriteMovies[index]);
                              }, moviesController: moviesController,

                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// MoviesController class for state management
class MovieController extends GetxController {
  RxList<Movies> allMovies = <Movies>[].obs;
  RxList<Movies> favoriteMovies = <Movies>[].obs;

  void setAllMovies(List<Movies> movies) {
    allMovies.assignAll(movies);
  }

  void updateFavorites(Movies movie) {
    if (favoriteMovies.contains(movie)) {
      favoriteMovies.remove(movie);
    } else {
      favoriteMovies.add(movie);
    }
  }
}

class MovieCard extends StatefulWidget {
  final Movies movie;
  final VoidCallback onFavoriteChanged;
  final MovieController moviesController;

  const MovieCard({
    required this.movie,
    required this.onFavoriteChanged,
    required this.moviesController,
  });

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.moviesController.favoriteMovies.contains(widget.movie);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: widget.movie.posterPath != null &&
                    widget.movie.posterPath!.isNotEmpty
                    ? Image.network(
                  'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                  fit: BoxFit.cover,
                )
                    : Placeholder(),
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
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          widget.onFavoriteChanged();
                          setState(() {
                            isFavorite = !isFavorite;
                          });
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
