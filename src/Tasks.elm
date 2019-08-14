port module Tasks exposing (Task, Tasks, concat, save)

import Json.Encode
import Maybe.Extra


type alias Tasks =
    -- List of tasks before the one currently being edited
    { before : List Task

    -- The task currently being edited
    , edit : Maybe Task

    -- List of tasks after the one currently being edited
    , after : List Task
    }


type alias Task =
    { id : Int
    , text : String
    }


concat : Tasks -> List Task
concat tasks =
    List.concat
        [ tasks.before
        , Maybe.Extra.toList tasks.edit
        , tasks.after
        ]


save : Tasks -> Cmd msg
save tasks =
    tasks
        |> concat
        |> Json.Encode.list (\task -> Json.Encode.string task.text)
        |> saveTasks


port saveTasks : Json.Encode.Value -> Cmd msg
