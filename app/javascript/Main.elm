module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    Int



-- INIT


init : ( Model, Cmd Message )
init =
    ( 0, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    -- The inline style is being used for example purposes in order to keep this example simple and
    -- avoid loading additional resources. Use a proper stylesheet when building your own app.
    div []
        [ h1 [ style "display" "flex", style "justify-content" "center" ]
            [ text ("Hello Elm! " ++ String.fromInt model) ]
        , button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]



-- MESSAGE


type Message
    = Increment
    | Decrement



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- MAIN


main : Program (Maybe {}) Model Message
main =
    Browser.element
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
