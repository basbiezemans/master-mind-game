module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown)
import Dict
import Feedback exposing (Feedback, makeFeedback)
import Guess exposing (Guess(..))
import Html exposing (Html, button, div, h1, img, p, span, text)
import Html.Attributes exposing (class, disabled, src, title)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (decodeString, dict)
import Json.Encode as Encode
import Maybe exposing (Maybe, withDefault)
import Ports
import Random
import Secret exposing (Secret(..))
import Utils exposing (maybe)



---- MODEL ----


type ButtonState
    = InitialState
    | SelectState
    | ReadyState


type ButtonType
    = GuessButton
    | SelectButton
    | DeselectButton


type GameState
    = Play ButtonState
    | Won
    | Lost


type alias LimitCounter =
    { count : Int
    , limit : Int
    }


type alias Score =
    { codeMaker : Int
    , codeBreaker : Int
    }


type alias Model =
    { counter : LimitCounter
    , secret : Secret
    , score : Score
    , guess : Guess
    , guesses : List ( Guess, Feedback )
    , gamestate : GameState
    }


type alias Digit =
    String


init : Maybe String -> ( Model, Cmd Msg )
init score =
    ( { counter = LimitCounter 0 10
      , secret = Secret.zeroFill
      , score = maybe (Score 0 0) fromJson score
      , guess = Guess.empty
      , guesses = []
      , gamestate = Play InitialState
      }
    , randomCode
    )



---- UPDATE ----


type Msg
    = Select Digit
    | Deselect
    | Void
    | GuessSecret
    | NewGame
    | NewSecret (List Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Select digit ->
            ( addSelectedDigit digit model, Cmd.none )

        Deselect ->
            ( removeLastDigit model, Cmd.none )

        Void ->
            ( model, Cmd.none )

        GuessSecret ->
            let
                latest =
                    evaluateGuess model
            in
            case latest.gamestate of
                Play _ ->
                    ( latest, Cmd.none )

                _ ->
                    ( latest, saveScore latest.score )

        NewSecret code ->
            ( { model | secret = Secret.fromList code }, Cmd.none )

        NewGame ->
            ( { model
                | counter = LimitCounter 0 10
                , guess = Guess.empty
                , guesses = []
                , gamestate = Play InitialState
              }
            , randomCode
            )


updateGuess : Digit -> Model -> Model
updateGuess digit model =
    case String.toInt digit of
        Nothing ->
            model

        Just int ->
            { model | guess = Guess.push int model.guess }


removeLastDigit : Model -> Model
removeLastDigit model =
    let
        guessLength =
            Guess.length model.guess

        buttonState =
            if guessLength > 1 then
                SelectState

            else
                InitialState
    in
    { model
        | guess = Guess.pop model.guess
        , gamestate = Play buttonState
    }


addSelectedDigit : Digit -> Model -> Model
addSelectedDigit digit model =
    let
        latest =
            updateGuess digit model
    in
    if Guess.isReady latest.guess then
        { latest | gamestate = Play ReadyState }

    else
        { latest | gamestate = Play SelectState }


equalCode : Guess -> Secret -> Bool
equalCode (Guess xs) (Secret ys) =
    xs == ys


evaluateGuess : Model -> Model
evaluateGuess model =
    let
        feedback =
            makeFeedback model.secret model.guess

        incremented =
            incCounter model

        latest =
            { incremented
                | guesses = model.guesses ++ [ ( model.guess, feedback ) ]
            }
    in
    if equalCode latest.guess model.secret then
        setGameState Won (addCodeBreakerPoint latest)

    else if isGameOver latest then
        setGameState Lost (addCodeMakerPoint latest)

    else
        { latest
            | guess = Guess.empty
            , gamestate = Play InitialState
        }


isGameOver : Model -> Bool
isGameOver model =
    let
        counter =
            model.counter
    in
    counter.count == counter.limit


incCounter : Model -> Model
incCounter model =
    let
        counter =
            model.counter

        count =
            counter.count
    in
    { model | counter = { counter | count = count + 1 } }


randomCode : Cmd Msg
randomCode =
    Random.generate NewSecret randomInts


randomInts : Random.Generator (List Int)
randomInts =
    Random.list 4 (Random.int 1 6)


setGameState : GameState -> Model -> Model
setGameState state model =
    { model | gamestate = state }


addCodeMakerPoint : Model -> Model
addCodeMakerPoint model =
    let
        score =
            model.score

        points =
            score.codeMaker
    in
    { model | score = { score | codeMaker = points + 1 } }


addCodeBreakerPoint : Model -> Model
addCodeBreakerPoint model =
    let
        score =
            model.score

        points =
            score.codeBreaker
    in
    { model | score = { score | codeBreaker = points + 1 } }



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        bkrPoints =
            String.fromInt model.score.codeBreaker

        mkrPoints =
            String.fromInt model.score.codeMaker
    in
    div [ class "content" ]
        [ div [ class "box score rounded" ]
            [ span [] [ text ("Code Maker: " ++ mkrPoints) ]
            , span [] [ text ("Code Breaker: " ++ bkrPoints) ]
            ]
        , case model.gamestate of
            Play _ ->
                viewPlay model

            Won ->
                viewWon model

            Lost ->
                viewLost model
        ]


currentGuess : Model -> String
currentGuess model =
    model.guess
        |> Guess.toList
        |> List.map String.fromInt
        |> List.foldr (++) ""
        |> String.padRight 4 '_'


isDisabled : ButtonType -> GameState -> Bool
isDisabled button state =
    case ( button, state ) of
        ( DeselectButton, Play InitialState ) ->
            True

        ( SelectButton, Play ReadyState ) ->
            True

        ( GuessButton, Play InitialState ) ->
            True

        ( GuessButton, Play SelectState ) ->
            True

        _ ->
            False


guessButton : GameState -> Html Msg
guessButton state =
    button
        [ onClick GuessSecret
        , disabled (isDisabled GuessButton state)
        ]
        [ text "Guess" ]


deselectButton : GameState -> Html Msg
deselectButton state =
    button
        [ onClick Deselect
        , disabled (isDisabled DeselectButton state)
        ]
        [ text "⌫" ]


selectButton : GameState -> Digit -> Html Msg
selectButton state digit =
    button
        [ onClick (Select digit)
        , disabled (isDisabled SelectButton state)
        ]
        [ text digit ]


selectButtons : GameState -> List (Html Msg)
selectButtons state =
    List.map (selectButton state) <| String.split "" "123456"


viewPlay : Model -> Html Msg
viewPlay model =
    let
        previousGuesses =
            List.map2 toListItem itemMarkers model.guesses

        state =
            model.gamestate
    in
    div []
        [ div
            [ class "box main rounded" ]
            [ h1 [] [ text "Master Mind" ]
            , div [ class "guess" ] [ text (currentGuess model) ]
            ]
        , div
            [ class "buttons" ]
            [ div [ class "box left" ] (deselectButton state :: selectButtons state)
            , div [ class "box right" ] [ guessButton state ]
            ]
        , div
            [ class "box feedback rounded" ]
            previousGuesses
        ]


viewWon : Model -> Html Msg
viewWon model =
    let
        previousGuesses =
            List.map2 toListItem itemMarkers model.guesses
    in
    div []
        [ div
            [ class "box main rounded" ]
            [ img [ src "assets/img/you-win.gif", title "You win!", class "congrats" ] [] ]
        , div [ class "box play" ]
            [ button
                [ class "play", onClick NewGame ]
                [ text "Play Again" ]
            ]
        , div
            [ class "box feedback rounded" ]
            previousGuesses
        ]


viewLost : Model -> Html Msg
viewLost model =
    let
        previousGuesses =
            List.map2 toListItem itemMarkers model.guesses
    in
    div []
        [ div
            [ class "box main rounded" ]
            [ h1 [] [ text "Master Mind" ]
            , p [ class "sorry" ] [ text "Sorry, you lost. The secret code was:" ]
            , div [ class "secret" ] [ text (Secret.toString model.secret) ]
            ]
        , div [ class "box play" ]
            [ button
                [ class "play", onClick NewGame ]
                [ text "Play Again" ]
            ]
        , div
            [ class "box feedback rounded" ]
            previousGuesses
        ]


toListItem : String -> ( Guess, Feedback ) -> Html msg
toListItem itemMarker ( guess, feedback ) =
    let
        marker =
            String.padRight 3 ' ' itemMarker
    in
    p [] [ text (marker ++ Guess.toString guess ++ " | " ++ Feedback.toString feedback) ]


itemMarkers : List String
itemMarkers =
    String.split "" "①②③④⑤⑥⑦⑧⑨⑩"



---- MAIN ----


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


saveScore : Score -> Cmd msg
saveScore score =
    scoreValue score
        |> Encode.encode 0
        |> Ports.storeScore


scoreValue : Score -> Encode.Value
scoreValue score =
    Encode.object
        [ ( "codeMaker", Encode.int score.codeMaker )
        , ( "codeBreaker", Encode.int score.codeBreaker )
        ]


fromJson : String -> Score
fromJson scoreJson =
    case decodeString (dict Decode.int) scoreJson of
        Ok score ->
            let
                codeMaker =
                    withDefault 0 (Dict.get "codeMaker" score)

                codeBreaker =
                    withDefault 0 (Dict.get "codeBreaker" score)
            in
            Score codeMaker codeBreaker

        Err _ ->
            Score 0 0


subscriptions : Model -> Sub Msg
subscriptions model =
    onKeyDown <| keyDecoder model


keyDecoder : Model -> Decode.Decoder Msg
keyDecoder model =
    let
        gameState =
            model.gamestate

        keyValue =
            Decode.field "key" Decode.string
    in
    Decode.map (handleKeyEvent gameState) keyValue


handleKeyEvent : GameState -> String -> Msg
handleKeyEvent gameState keyValue =
    case ( gameState, keyValue ) of
        ( Play _, "Backspace" ) ->
            Deselect

        ( Play _, "Enter" ) ->
            GuessSecret

        ( Play _, _ ) ->
            handleCharKey keyValue

        ( _, "Enter" ) ->
            NewGame

        _ ->
            Void


handleCharKey : String -> Msg
handleCharKey keyValue =
    case String.uncons keyValue of
        Just ( char, "" ) ->
            if isValidDigit char then
                Select <| String.fromChar char

            else
                Void

        _ ->
            Void


isValidDigit : Char -> Bool
isValidDigit char =
    let
        validDigits =
            [ '1', '2', '3', '4', '5', '6' ]
    in
    Char.isDigit char && List.any ((==) char) validDigits
