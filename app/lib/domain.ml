type dockerWebHookEvent = DockerWebHookEvent of string
type telegramMessage = TelegramMessage of string * string

let handleEvent event =
  match event with
  | `DockerWebHookEvent (DockerWebHookEvent _) -> ()
  | `TelegramMessage (TelegramMessage _) -> ()

let dispatch _ = ()

let add a b =
  dispatch (DockerWebHookEvent "");
  dispatch (TelegramMessage ("", ""));
  a + b

let run_application () =
  let _x = add 2 2 in
  print_endline @@ "Hello, World! = " ^ string_of_int _x
