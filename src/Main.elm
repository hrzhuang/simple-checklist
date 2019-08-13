module Main exposing (main)

import Browser
import Browser.Dom
import FontAwesome.Icon
import FontAwesome.Solid
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Html.Keyed
import List.Extra
import Maybe.Extra
import Svg.Attributes
import Task
import Tasks exposing (Task, Tasks)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , subscriptions = \_ -> Sub.none
        , update = update
        }



-- MODEL


type alias Model =
    { tasks : Tasks
    , nextTaskId : Int
    }


init : () -> ( Model, Cmd Msg )
init () =
    let
        initialTaskId =
            0
    in
    ( { tasks =
            { before = []
            , edit = Just { id = initialTaskId, text = "" }
            , after = []
            }
      , nextTaskId = initialTaskId + 1
      }
    , focusEdit
    )



-- UPDATE


type Msg
    = AddTask
    | RemoveTask Int
    | StartEdit Int
    | UpdateEdit String
    | FinishEdit
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask ->
            let
                nextTaskId =
                    model.nextTaskId
            in
            ( { tasks =
                    { before = []
                    , edit = Just { id = nextTaskId, text = "" }
                    , after = Tasks.concat model.tasks
                    }
              , nextTaskId = nextTaskId + 1
              }
            , focusEdit
            )

        RemoveTask id ->
            ( { model
                | tasks =
                    { before = []
                    , edit = Nothing
                    , after =
                        model.tasks
                            |> Tasks.concat
                            |> List.filter (\task -> task.id /= id)
                    }
              }
            , Cmd.none
            )

        StartEdit id ->
            ( { model
                | tasks =
                    let
                        all =
                            Tasks.concat model.tasks

                        ( before, rest ) =
                            List.Extra.span (\task -> task.id /= id) all

                        ( edit, after ) =
                            case List.Extra.uncons rest of
                                Just ( head, tail ) ->
                                    ( Just head, tail )

                                -- This should never happen
                                Nothing ->
                                    ( Nothing, [] )
                    in
                    { before = before
                    , edit = edit
                    , after = after
                    }
              }
            , focusEdit
            )

        UpdateEdit newText ->
            ( { model
                | tasks =
                    let
                        tasks =
                            model.tasks
                    in
                    { tasks
                        | edit =
                            case tasks.edit of
                                Just edit ->
                                    Just
                                        { edit
                                            | text = newText
                                        }

                                -- This should never happen
                                Nothing ->
                                    Nothing
                    }
              }
            , Cmd.none
            )

        FinishEdit ->
            ( { model
                | tasks =
                    { before = model.tasks.before
                    , edit = Nothing
                    , after =
                        case model.tasks.edit of
                            Just edit ->
                                if String.isEmpty edit.text then
                                    model.tasks.after

                                else
                                    edit :: model.tasks.after

                            Nothing ->
                                model.tasks.after
                    }
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- COMMANDS


focusEdit : Cmd Msg
focusEdit =
    Browser.Dom.focus "edit-text-field"
        |> Task.attempt (\_ -> NoOp)



-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.class "h-100 d-flex flex-column"
        ]
        [ viewHeaderBar
        , if
            model.tasks
                |> Tasks.concat
                |> List.isEmpty
          then
            viewEmptyState

          else
            viewTasks model.tasks
        ]


viewHeaderBar : Html Msg
viewHeaderBar =
    Html.header
        [ Html.Attributes.class "navbar navbar-dark bg-primary sticky-top"
        ]
        [ Html.div
            [ Html.Attributes.class "navbar-brand"
            ]
            [ Html.text "Simple Checklist" ]
        , Html.form
            [ Html.Attributes.class "form-inline"
            ]
            [ Html.button
                [ Html.Attributes.type_ "button"
                , Html.Attributes.class "btn btn-primary"
                , Html.Events.onClick AddTask
                ]
                [ FontAwesome.Icon.viewIcon FontAwesome.Solid.plus ]
            ]
        ]


viewEmptyState : Html Msg
viewEmptyState =
    Html.main_
        [ Html.Attributes.class "flex-grow-1"
        , Html.Attributes.class "d-flex flex-column"
        , Html.Attributes.class "justify-content-center align-items-center"
        ]
        [ FontAwesome.Icon.viewStyled
            [ Svg.Attributes.class "w-25 h-25 text-muted"
            ]
            FontAwesome.Solid.clipboardCheck
        , Html.h2
            [ Html.Attributes.class "mt-3 mb-0 text-muted"
            ]
            [ Html.text "All done" ]
        , Html.p
            [ Html.Attributes.class "mt-1 mb-0 w-75 text-center text-muted"
            ]
            [ Html.text "Now take a break or add a new task." ]
        ]


viewTasks : Tasks -> Html Msg
viewTasks tasks =
    Html.main_
        [ Html.Attributes.class "p-4"
        ]
        [ Html.Keyed.ul
            [ Html.Attributes.class "list-group" ]
          <|
            List.concat
                [ List.map viewTask tasks.before
                , tasks.edit
                    |> Maybe.map viewEdit
                    |> Maybe.Extra.toList
                , List.map viewTask tasks.after
                ]
        ]


viewTask : Task -> ( String, Html Msg )
viewTask task =
    let
        key =
            String.fromInt task.id

        node =
            Html.li
                [ Html.Attributes.class "list-group-item"
                , Html.Attributes.class "d-flex align-items-center"
                ]
                [ Html.button
                    [ Html.Attributes.class "btn btn-outline-primary btn-sm"
                    , Html.Events.onClick (RemoveTask task.id)
                    ]
                    [ FontAwesome.Icon.viewIcon FontAwesome.Solid.check ]
                , Html.div
                    [ Html.Attributes.class "ml-3 w-100 h-100 min-height-100"
                    , Html.Attributes.class "cursor-pointer"
                    , Html.Events.onClick (StartEdit task.id)
                    ]
                    [ Html.text task.text ]
                ]
    in
    ( key, node )


viewEdit : Task -> ( String, Html Msg )
viewEdit edit =
    let
        key =
            String.fromInt edit.id

        node =
            Html.li
                [ Html.Attributes.class "list-group-item"
                , Html.Attributes.class "d-flex align-items-center"
                ]
                [ Html.button
                    [ Html.Attributes.class "btn btn-outline-primary btn-sm"
                    ]
                    [ FontAwesome.Icon.viewIcon FontAwesome.Solid.check ]
                , Html.form
                    [ Html.Attributes.class "form-inline"
                    , Html.Attributes.class "flex-grow-1"
                    , Html.Events.onSubmit FinishEdit
                    ]
                    [ Html.input
                        [ Html.Attributes.type_ "text"
                        , Html.Attributes.class "form-control"
                        , Html.Attributes.class "form-control-sm"
                        , Html.Attributes.class "ml-3 w-100"
                        , Html.Attributes.id "edit-text-field"
                        , Html.Attributes.autocomplete False
                        , Html.Events.onBlur FinishEdit
                        , Html.Events.onInput UpdateEdit
                        , Html.Attributes.value edit.text
                        ]
                        []
                    ]
                ]
    in
    ( key, node )
