import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Html.Events exposing (onWithOptions, targetChecked, on)
import Json.Decode as Json

--MAIN--
main : Program Never Model Action
main =
    Html.beginnerProgram
     { 
         model = model,
         view  = view,
         update = update
     }

-- MODEL--
type alias Goal =
    { 
        id : Int,
        name : String,
        value : String, 
        completed : Bool
    }

type alias Model =
    {
        score : Int,
        goals : List Goal,
        currentGoalName : String,
        currentGoalScore : String
    }

--Inital Model State
model : Model
model = 
    { 
        score = 1000,
        goals = [Goal 1 "Love Kalie Forever" "100" False],
        currentGoalName = "",
        currentGoalScore = ""
    }

--ACTION TYPES--
type Action = NoOp
    | AddGoal String String
    | ToggleGoalComplete Int Bool
    | UpdateGoalName Int String
    | ToggleScore Goal
    | ChangeCurrentGoalName String
    | ChangeCurrentGoalScore String

--UPDATE--

update : Action -> Model -> Model
update action model =
    case action of
        NoOp ->
            model
        AddGoal name score ->
            { model | goals = model.goals ++ [Goal (createNewID (findMaxID model.goals)) name score False] }
        ToggleGoalComplete id status ->
            let
              newGoals =
                List.map
                    (\goal ->
                        if goal.id == id then
                            { goal | completed = status }
                        else
                            goal
                    )
                    model.goals
            in
                { model | goals = newGoals }
        UpdateGoalName id newName ->
            let
              newGoals =
                List.map
                    (\goal ->
                        if goal.id == id then
                            { goal | name = newName }
                        else
                            goal
                    )
                    model.goals
            in
                { model | goals = newGoals }
              
        ToggleScore goal ->
            if goal.completed == False then
                { model | 
                    score = model.score + Result.withDefault 0 (String.toInt goal.value) }
            else
                { model | score = model.score - Result.withDefault 0 (String.toInt goal.value) }

        ChangeCurrentGoalName name ->
            { model | currentGoalName = name }
        ChangeCurrentGoalScore score ->
            { model | currentGoalScore = score }

--MAILBOXES--

{-inbox : Signal.Mailbox Action --this inbox stores a Mailbox type that stores Actions
inbox =
    Signal.mailbox NoOp --set initial value of mailbox // mailboxes return a record with the keys address and signal
    --inbox.address gives address of mailbox with initial value
    --inbox.signal gives signal of values getting stored in mailbox

modelSignal : Signal Model
modelSignal =
    Signal.foldp update model inbox.signal

    --}


-- view : Signal.Address Action -> Model -> Html
-- view address person =
--     div [] [
--         h2 [] 
--     ]



--VIEW--

type alias Options =
    {
        stopPropagation : Bool,
        preventDefault : Bool
    }

view : Model -> Html Action
view model = 
    div [ class "container" ]
        [ 
            div [ class "jumbotron text-center" ] 
                [ 
                    h1 [] [ text "Achieve" ]
                ],
            div [ class "row" ]
            [ 
                div [ class "col-lg-4 col-md-4" ]
                    [ 
                        h1 [ class "text=center" ] [ text "New Goal: " ],
                        Html.form [ class "form-group" ]
                            [ 
                                label [ for "goalNameInput" ] [ text "Goal: " ],
                                input [ id "goalNameInput", class "form-control", onInput ChangeCurrentGoalName ] [],
                                label [ for "goalScoreInput" ] [ text "Goal Value: " ],
                                input [ id "goalScoreInput", class "form-control", onInput ChangeCurrentGoalScore  ] [],
                                button [class "btn btn-md btn primary", onWithOptions "click" (Options False True) (Json.succeed (AddGoal model.currentGoalName model.currentGoalScore)) ] [text "Submit"] 
                            ]
                    ],
                div [class "col-lg-4 col-md-4"]
                    [
                        h1 [ class "text-center" ] [ text "My Goals" ],
                        renderGoals model.goals
                    ],
                div [ class "col-lg-4 col-mid-4" ]
                    [
                        div [class "row"]
                            [
                                h1 [ class "text-center" ] [ text "Score" ],
                                h2 [ class "text-center" ] [ text (toString model.score) ]  
                            ]
                    ]
            ]
        ]


renderGoals : List Goal -> Html Action
renderGoals goals =
    ul [class "list-unstyled text-center"]
        (List.map 
                (\goal -> 
                    li [ class "list-item" ] 
                    [ 
                        label [] 
                        [ 
                            input [class "form-control", type_ "checkbox", onClick (ToggleScore goal) ] [], 
                            text ((toString goal.name) ++ " - "), text goal.value 
                        ] 
                    ]) 
        goals)


--HELPERS--

updateGoalComplete : Goal -> Bool -> Goal
updateGoalComplete goal value =
    {goal | completed = value }


--searches through a list of records and finds the max id present
findMaxID : List Goal -> Int
findMaxID records = 
    records
        |> List.map (.id)
        |> List.maximum
        |> Maybe.withDefault -1

--create a new id
createNewID : Int -> Int
createNewID id = 
    id + 1


        
