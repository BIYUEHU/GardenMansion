module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- MODEL

type alias Model =
    { currentPage : Page
    , messages : List Message
    , expenses : List Expense
    , users : List User
    , newMessage : String
    , newExpense : ExpenseForm
    }

type Page
    = MessagesPage
    | ExpensesPage
    | UsersPage

type alias Message =
    { id : Int
    , author : String
    , content : String
    , timestamp : Int
    }

type alias Expense =
    { id : Int
    , name : String
    , amount : Float
    , paidBy : String
    , date : String
    , note : String
    }

type alias User =
    { id : Int
    , name : String
    , status : String
    , avatar : String
    }

type alias ExpenseForm =
    { name : String
    , amount : String
    , note : String
    }

initialModel : Model
initialModel =
    { currentPage = MessagesPage
    , messages = sampleMessages
    , expenses = sampleExpenses
    , users = sampleUsers
    , newMessage = ""
    , newExpense = { name = "", amount = "", note = "" }
    }

sampleMessages : List Message
sampleMessages =
    [ { id = 1, author = "小明", content = "今天买了一些生活用品，大家记得分摊费用哦~", timestamp = 1234567890 }
    , { id = 2, author = "阿花", content = "周末准备大扫除，有空的室友一起帮忙吧！", timestamp = 1234567800 }
    ]

sampleExpenses : List Expense
sampleExpenses =
    [ { id = 1, name = "电费", amount = 128.50, paidBy = "小明", date = "2024年9月", note = "" }
    , { id = 2, name = "网费", amount = 89.00, paidBy = "阿花", date = "2024年9月", note = "" }
    , { id = 3, name = "生活用品", amount = 45.80, paidBy = "小李", date = "昨天", note = "" }
    ]

sampleUsers : List User
sampleUsers =
    [ { id = 1, name = "小明", status = "在线", avatar = "明" }
    , { id = 2, name = "阿花", status = "2小时前", avatar = "花" }
    , { id = 3, name = "小李", status = "昨天", avatar = "李" }
    ]


-- UPDATE

type Msg
    = ChangePage Page
    | UpdateNewMessage String
    | AddMessage
    | UpdateExpenseName String
    | UpdateExpenseAmount String
    | UpdateExpenseNote String
    | AddExpense

update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangePage page ->
            { model | currentPage = page }

        UpdateNewMessage content ->
            { model | newMessage = content }

        AddMessage ->
            if String.isEmpty (String.trim model.newMessage) then
                model
            else
                let
                    newMessage =
                        { id = List.length model.messages + 1
                        , author = "我"
                        , content = model.newMessage
                        , timestamp = 1234567890
                        }
                in
                { model 
                | messages = newMessage :: model.messages
                , newMessage = ""
                }

        UpdateExpenseName name ->
            let
                oldForm = model.newExpense
                newForm = { oldForm | name = name }
            in
            { model | newExpense = newForm }

        UpdateExpenseAmount amount ->
            let
                oldForm = model.newExpense
                newForm = { oldForm | amount = amount }
            in
            { model | newExpense = newForm }

        UpdateExpenseNote note ->
            let
                oldForm = model.newExpense
                newForm = { oldForm | note = note }
            in
            { model | newExpense = newForm }

        AddExpense ->
            let
                form = model.newExpense
            in
            if String.isEmpty (String.trim form.name) || String.isEmpty (String.trim form.amount) then
                model
            else
                case String.toFloat form.amount of
                    Just amountFloat ->
                        let
                            newExpense =
                                { id = List.length model.expenses + 1
                                , name = form.name
                                , amount = amountFloat
                                , paidBy = "我"
                                , date = "刚刚"
                                , note = form.note
                                }
                            
                            resetForm = { name = "", amount = "", note = "" }
                        in
                        { model 
                        | expenses = newExpense :: model.expenses
                        , newExpense = resetForm
                        }
                    
                    Nothing ->
                        model


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ viewHeader
        , div [ class "main-content" ]
            [ viewNavigation model.currentPage
            , viewCurrentPage model
            ]
        ]

viewHeader : Html Msg
viewHeader =
    header [ class "header" ]
        [ h1 [] [ text "🏠 合租管理系统" ]
        , p [] [ text "千禧年代的数字化合租生活" ]
        ]

viewNavigation : Page -> Html Msg
viewNavigation currentPage =
    nav [ class "nav-tabs" ]
        [ button 
            [ class (if currentPage == MessagesPage then "nav-tab active" else "nav-tab")
            , onClick (ChangePage MessagesPage)
            ] 
            [ text "留言板" ]
        , button 
            [ class (if currentPage == ExpensesPage then "nav-tab active" else "nav-tab")
            , onClick (ChangePage ExpensesPage)
            ] 
            [ text "费用管理" ]
        , button 
            [ class (if currentPage == UsersPage then "nav-tab active" else "nav-tab")
            , onClick (ChangePage UsersPage)
            ] 
            [ text "室友管理" ]
        ]

viewCurrentPage : Model -> Html Msg
viewCurrentPage model =
    case model.currentPage of
        MessagesPage ->
            viewMessagesPage model

        ExpensesPage ->
            viewExpensesPage model

        UsersPage ->
            viewUsersPage model

viewMessagesPage : Model -> Html Msg
viewMessagesPage model =
    div [ class "content-section" ]
        [ div [ class "message-board" ]
            [ h3 [ style "margin-bottom" "1.5rem", style "color" "#2d3748" ] [ text "💬 最新留言" ]
            , div [] (List.map viewMessage model.messages)
            ]
        , Html.form [ onSubmit AddMessage ]
            [ div [ class "form-group" ]
                [ label [ class "form-label" ] [ text "发布新留言" ]
                , textarea 
                    [ class "form-textarea"
                    , placeholder "分享你的想法或通知..."
                    , value model.newMessage
                    , onInput UpdateNewMessage
                    ] []
                ]
            , button [ class "btn", type_ "button", onClick AddMessage ] [ text "发布留言" ]
            ]
        ]

viewMessage : Message -> Html Msg
viewMessage message =
    div [ class "message-item" ]
        [ div [ class "message-header" ]
            [ span [ class "message-author" ] [ text message.author ]
            , span [ class "message-time" ] [ text "刚刚" ]
            ]
        , div [ class "message-content" ] [ text message.content ]
        ]

viewExpensesPage : Model -> Html Msg
viewExpensesPage model =
    div [ class "content-section" ]
        [ h3 [ style "margin-bottom" "1.5rem", style "color" "#2d3748" ] [ text "💰 本月费用统计" ]
        , div [] (List.map viewExpense model.expenses)
        , Html.form [ onSubmit AddExpense, style "margin-top" "2rem" ]
            [ div [ class "form-group" ]
                [ label [ class "form-label" ] [ text "费用名称" ]
                , input 
                    [ type_ "text"
                    , class "form-input"
                    , placeholder "如：电费、水费、生活用品等"
                    , value model.newExpense.name
                    , onInput UpdateExpenseName
                    ] []
                ]
            , div [ class "form-group" ]
                [ label [ class "form-label" ] [ text "金额" ]
                , input 
                    [ type_ "number"
                    , class "form-input"
                    , placeholder "0.00"
                    , step "0.01"
                    , value model.newExpense.amount
                    , onInput UpdateExpenseAmount
                    ] []
                ]
            , div [ class "form-group" ]
                [ label [ class "form-label" ] [ text "备注" ]
                , input 
                    [ type_ "text"
                    , class "form-input"
                    , placeholder "可选的备注信息"
                    , value model.newExpense.note
                    , onInput UpdateExpenseNote
                    ] []
                ]
            , button [ class "btn", type_ "button", onClick AddExpense ] [ text "添加费用" ]
            ]
        ]

viewExpense : Expense -> Html Msg
viewExpense expense =
    div [ class "expense-item" ]
        [ div [ class "expense-info" ]
            [ h4 [] [ text expense.name ]
            , p [] [ text (expense.paidBy ++ "代付 • " ++ expense.date) ]
            ]
        , div [ class "expense-amount" ] [ text ("¥" ++ String.fromFloat expense.amount) ]
        ]

viewUsersPage : Model -> Html Msg
viewUsersPage model =
    div [ class "content-section" ]
        [ h3 [ style "margin-bottom" "1.5rem", style "color" "#2d3748" ] [ text "👥 室友列表" ]
        , div [ class "user-list" ] (List.map viewUser model.users ++ [ viewAddUserCard ])
        ]

viewUser : User -> Html Msg
viewUser user =
    div [ class "user-card" ]
        [ div [ class "user-avatar" ] [ text user.avatar ]
        , div [ class "user-name" ] [ text user.name ]
        , div [ class "user-status" ] [ text user.status ]
        ]

viewAddUserCard : Html Msg
viewAddUserCard =
    div 
        [ class "user-card"
        , style "border" "2px dashed #cbd5e0"
        , style "background" "#f7fafc"
        ]
        [ div 
            [ class "user-avatar"
            , style "background" "#cbd5e0"
            , style "color" "#64748b"
            ] [ text "+" ]
        , div 
            [ class "user-name"
            , style "color" "#64748b"
            ] [ text "添加室友" ]
        , div 
            [ class "user-status"
            , style "color" "#64748b"
            ] [ text "点击邀请" ]
        ]


-- CSS STYLES (这些需要放在HTML文件中)

styles : String
styles = """
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    color: #2d3748;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

.header {
    text-align: center;
    margin-bottom: 3rem;
    color: white;
}

.header h1 {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
    text-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header p {
    font-size: 1.1rem;
    opacity: 0.9;
}

.main-content {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 20px;
    padding: 2.5rem;
    box-shadow: 0 20px 40px rgba(0,0,0,0.1);
    backdrop-filter: blur(10px);
}

.nav-tabs {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 2rem;
    background: #f7fafc;
    padding: 0.5rem;
    border-radius: 12px;
}

.nav-tab {
    flex: 1;
    padding: 0.75rem 1.5rem;
    text-align: center;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.3s ease;
    border: none;
    background: transparent;
    color: #64748b;
}

.nav-tab.active {
    background: #667eea;
    color: white;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.nav-tab:hover:not(.active) {
    background: #e2e8f0;
}

.message-board {
    background: #f8fafc;
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 2rem;
}

.message-item {
    background: white;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1rem;
    border-left: 4px solid #667eea;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.message-item:last-child {
    margin-bottom: 0;
}

.message-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
}

.message-author {
    font-weight: 600;
    color: #667eea;
}

.message-time {
    font-size: 0.875rem;
    color: #64748b;
}

.message-content {
    color: #4a5568;
    line-height: 1.6;
}

.expense-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: white;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 0.75rem;
    border: 1px solid #e2e8f0;
}

.expense-info h4 {
    color: #2d3748;
    margin-bottom: 0.25rem;
}

.expense-info p {
    font-size: 0.875rem;
    color: #64748b;
}

.expense-amount {
    font-weight: 700;
    font-size: 1.125rem;
    color: #e53e3e;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #374151;
}

.form-input, .form-textarea {
    width: 100%;
    padding: 0.75rem;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    font-size: 1rem;
    transition: border-color 0.3s ease;
}

.form-input:focus, .form-textarea:focus {
    outline: none;
    border-color: #667eea;
}

.form-textarea {
    min-height: 100px;
    resize: vertical;
}

.btn {
    background: #667eea;
    color: white;
    border: none;
    padding: 0.75rem 2rem;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
    font-size: 1rem;
}

.btn:hover {
    background: #5a67d8;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.user-list {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
}

.user-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    text-align: center;
    border: 2px solid #e2e8f0;
    transition: all 0.3s ease;
}

.user-card:hover {
    border-color: #667eea;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.user-avatar {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: #667eea;
    margin: 0 auto 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.5rem;
    font-weight: 700;
}

.user-name {
    font-weight: 600;
    margin-bottom: 0.5rem;
}

.user-status {
    font-size: 0.875rem;
    color: #10b981;
}

@media (max-width: 768px) {
    .container {
        padding: 1rem;
    }

    .main-content {
        padding: 1.5rem;
    }

    .nav-tabs {
        flex-direction: column;
    }

    .header h1 {
        font-size: 2rem;
    }
}
"""


-- MAIN

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }