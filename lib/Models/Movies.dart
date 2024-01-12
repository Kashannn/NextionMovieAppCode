class Movies {
  final int id;
  final String name;
  final double rating;
  final String? discription;
  final String? date;
  final String? posterPath;
  final String? originalLanguage;
  final String? favoriteMovies;
  final String? onFavoriteChanged;

  Movies({
    required this.id,
    required this.name,
    required this.rating,
    required this.discription,
    required this.date,
    required this.posterPath,
    required this.originalLanguage,
    required this.favoriteMovies,
    required this.onFavoriteChanged,
  });

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      id: json['id'],
      name: json['title'],
      rating: (json['vote_average'] != null) ? (json['vote_average']! as num).toDouble() : 0.0,
      discription: json['overview'],
      date: json['release_date'],
      posterPath: json['poster_path'],
      originalLanguage: json['original_language'],
      favoriteMovies: json['favoriteMovies'],
      onFavoriteChanged: json['onFavoriteChanged'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': name,
        'vote_average': rating,
        'overview': discription,
        'release_date': date,
        'poster_path': posterPath,
        'original_language': originalLanguage,
        'favoriteMovies': favoriteMovies,
        'onFavoriteChanged': onFavoriteChanged,

      };

  static List<Movies> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((movieJson) {
      if (movieJson is Map<String, dynamic>) {
        return Movies.fromJson(movieJson);
      } else {
        // Handle the case where the data is not in the expected format
        return Movies(
          id: -1, // Provide a default value or handle accordingly
          name: "Unknown",
          rating: 0.0,
          discription: null,
          date: null,
          posterPath: null,
          originalLanguage: null,
          favoriteMovies: null,
          onFavoriteChanged: null,
        );
      }
    }).toList();
  }
  }
