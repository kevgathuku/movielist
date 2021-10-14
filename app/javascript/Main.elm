module Main exposing (main)

-- Press a button to send a GET request for random cat GIFs.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, map2, map4, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Movie =
    { title : String
    , releaseDate : String
    , overview : String
    , poster : String
    }


type alias MovieList =
    { page : Int, movies : List Movie }


type Model
    = Failure
    | Loading
    | MoviesLoaded MovieList


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getTopRatedMovies "1" )



-- UPDATE


type Msg
    = Reload
    | NextPage
    | GotPopularMovies (Result Http.Error MovieList)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reload ->
            case model of
                MoviesLoaded movieList ->
                    ( Loading, getTopRatedMovies (String.fromInt movieList.page) )

                _ ->
                    ( Loading, Cmd.none )

        NextPage ->
            case model of
                MoviesLoaded movieList ->
                    ( Loading, getTopRatedMovies (String.fromInt (movieList.page + 1)) )

                _ ->
                    ( Loading, Cmd.none )

        GotPopularMovies result ->
            case result of
                Ok movieList ->
                    ( MoviesLoaded movieList, Cmd.none )

                Err error ->
                    let
                        _ =
                            Debug.toString error
                    in
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Popular Movies" ]
        , viewMovies model
        ]


viewMovies : Model -> Html Msg
viewMovies model =
    case model of
        Failure ->
            div []
                [ text "I could not load the popular movies for some reason. "
                , button [ onClick Reload ] [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading..."

        MoviesLoaded movieList ->
            div []
                [ button [ onClick NextPage, style "display" "block" ] [ text "Next Page!" ]
                , h3 [] [ text ("Page: " ++ String.fromInt movieList.page) ]
                , div [] (List.map viewMovie movieList.movies)
                ]


viewMovie : Movie -> Html Msg
viewMovie movie =
    div []
        [ h3 [] [ text movie.title ]
        , p [] [ text movie.overview ]
        ]



-- HTTP


getTopRatedMovies : String -> Cmd Msg
getTopRatedMovies page =
    Http.get
        { url = "https://api.themoviedb.org/3/movie/top_rated?api_key=ab6e113b8f90faa8fd9b085e8bdf437d&language=en-US&page=" ++ page
        , expect = Http.expectJson GotPopularMovies popularMoviesDecoder
        }


movieDecoder : Decoder Movie
movieDecoder =
    map4 Movie
        (field "title" string)
        (field "release_date" string)
        (field "overview" string)
        (field "poster_path" string)


popularMoviesDecoder : Decoder MovieList
popularMoviesDecoder =
    map2 MovieList
        (field "page" int)
        (field "results" (Json.Decode.list movieDecoder))
