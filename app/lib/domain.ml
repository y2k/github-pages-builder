open Event_bus

type cmd += RunShell of string

type msg += DockerWebHookEvent of string

module MsgHandler = struct
  let handle_msg (token : string) (msg : msg) : cmd list =
    match msg with
    | DockerWebHookEvent json ->
        let open Yojson.Basic.Util in
        let data = Yojson.Basic.from_string json in
        let repo =
          data |> member "repository" |> member "repo_name" |> to_string
        and name = data |> member "repository" |> member "name" |> to_string
        and repo_dir = "__repo__"
        and build_dir = "__build__" in
        if String.starts_with ~prefix:"y2khub/" repo then
          [ RunShell ("rm -rf " ^ repo_dir)
          ; RunShell ("rm -rf " ^ build_dir)
          ; RunShell
              (Printf.sprintf
                 "git clone https://y2khub:%s@github.com/y2k/y2k.github.io %s"
                 token repo_dir )
          ; RunShell
              (Printf.sprintf
                 {|cd %s && git config user.email "itwisterlx@gmail.com" && git config user.name "y2k"|}
                 repo_dir )
          ; RunShell (Printf.sprintf "rm -rf %s/%s" repo_dir name)
          ; RunShell (Printf.sprintf "docker pull %s" repo)
          ; RunShell
              (Printf.sprintf
                 "docker run --rm -v gpbuilder_shared:/build_result %s" repo )
          ; RunShell (Printf.sprintf "cp -r %s %s/%s" build_dir repo_dir name)
          ; RunShell
              (Printf.sprintf
                 "cd %s && git add . && git commit -m \"Update %s\" && git push"
                 repo_dir repo ) ]
        else []
    | _ ->
        []
end

module CommandHandler = struct
  let log_cmd cmd =
    ( match cmd with
    | RunShell cmd ->
        Printf.sprintf "LOG: [CMD][RunShell] %s\n" cmd
    | cmd ->
        let open Obj.Extension_constructor in
        Printf.sprintf "LOG: [CMD][%s]" (name (of_val cmd)) )
    |> print_endline

  let handle_cmd cmd =
    log_cmd cmd ;
    match cmd with RunShell cmd -> Unix.system cmd |> ignore | _ -> ()
end

let log_msg = function
  | DockerWebHookEvent data ->
      Printf.printf "LOG: [MSG][DockerWebHookEvent] '%s'\n" data ;
      flush stdout
  | msg ->
      let open Obj.Extension_constructor in
      print_endline @@ "LOG: [MSG][" ^ name (of_val msg) ^ "]"

let make_dispatch token json =
  let module EventBus =
    Make_EventBus
      (struct
        let handle_msg msg =
          log_msg msg ;
          MsgHandler.handle_msg token msg
      end)
      (CommandHandler)
  in
  EventBus.dispatch (DockerWebHookEvent json)
