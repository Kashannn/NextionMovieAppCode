import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart'; // Import Get
import '../API/CallApi.dart';
import '../Models/Movies.dart';

class AllMovies extends StatefulWidget {
  AllMovies({Key? key}) : super(key: key);

  @override
  _AllMoviesState createState() => _AllMoviesState();
}

class _AllMoviesState extends State<AllMovies> {
  // Declare a controller for state management
  final MoviesController moviesController = Get.put(MoviesController());

  @override
  void initState() {
    super.initState();
    getAllMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'All Movies',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Obx(
            () => moviesController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : Container(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: moviesController.allMovies.length,
            itemBuilder: (context, index) {
              return buildCustomMovieCard(moviesController.allMovies[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget buildCustomMovieCard(Movies movie) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            movie.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          RatingBar.builder(
            initialRating: movie.rating / 2,
            itemCount: 5,
            itemSize: 18,
            allowHalfRating: true,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {},
          ),
          SizedBox(height: 5),
          Text(
            movie.discription ?? "",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _showFullDescriptionDialog(context, movie);
            },
            child: Text(
              "View Details",
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getAllMovies() async {
    try {
      moviesController.setLoading(true); // Set loading to true

      final response = await CallApi().getData('discover/movie');

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        if (decodedData != null && decodedData['results'] is List) {
          List<dynamic> results = decodedData['results'];
          List<Movies> moviesList = Movies.listFromJson(results);

          print("Length: ${moviesList.length}");

          // Update the state using the controller
          moviesController.setAllMovies(moviesList);
        } else {
          print("Invalid data format in the API response.");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception caught: $e");
    } finally {
      moviesController.setLoading(false); // Set loading to false after API call
    }
  }

  void _showFullDescriptionDialog(BuildContext context, Movies movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Movie Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Title: ${movie.name}"),
              Text("Rating: ${movie.rating}"),
              Text("Release Date: ${movie.date ?? 'N/A'}"),
              Text("Original Language: ${movie.originalLanguage ?? 'N/A'}"),
              SizedBox(height: 10),
              Text("Overview:"),
              Text(movie.discription ?? "No description available."),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

// MoviesController class for state management
class MoviesController extends GetxController {
  RxList<Movies> allMovies = <Movies>[].obs;
  RxBool isLoading = true.obs;

  void setAllMovies(List<Movies> movies) {
    allMovies.assignAll(movies);
  }


  void setLoading(bool value) {
    isLoading.value = value;
  }
}
