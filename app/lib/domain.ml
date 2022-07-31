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
        and dir = "__data__" in
        if String.starts_with ~prefix:"y2khub/" repo then
          [ RunShell ("rm -rf " ^ dir)
          ; RunShell
              (Printf.sprintf
                 "git clone https://y2khub:%s@github.com/y2k/y2k.github.io %s"
                 token dir )
          ; RunShell (Printf.sprintf "docker pull %s" repo)
          ; RunShell
              (Printf.sprintf "docker run --rm -v $PWD/%s/%s:/build_result %s"
                 dir name repo )
          ; RunShell
              (Printf.sprintf
                 "cd %s && git add . && git commit -m \"Update %s\" && git push"
                 dir repo ) ]
        else []
    | _ ->
        []
end

module CommandHandler = struct
  let handle_cmd = function
    | RunShell cmd ->
        Printf.printf "LOG: [CMD][RunShell] %s\n" cmd ;
        flush stdout ;
        Unix.system cmd |> ignore
    | _ ->
        print_endline "LOG: "
end

let log = function
  | DockerWebHookEvent data ->
      Printf.printf "LOG: [MSG][DockerWebHookEvent] '%s'\n" data ;
      flush stdout
  | _ ->
      print_endline "LOG: Unknown event"

let make_dispatch token json =
  let module EventBus =
    Make_EventBus
      (struct
        let handle_msg msg =
          log msg ;
          MsgHandler.handle_msg token msg
      end)
      (CommandHandler)
  in
  EventBus.dispatch (DockerWebHookEvent json)
