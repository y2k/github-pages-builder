module Make_EventBus (T : sig
  type m

  type c
end) (H : sig
  val handle_msg : T.m -> T.c list
end) (CH : sig
  val handle_cmd : T.c -> unit
end) =
struct
  let dispatch (msg : T.m) : unit = H.handle_msg msg |> List.iter CH.handle_cmd
end

type msg = DockerWebHookEvent of string

type cmd = RunShell of string

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
        [ RunShell ("rm -rf " ^ dir)
        ; RunShell
            (Printf.sprintf
               "git clone https://y2khub:%s@github.com/y2k/y2k.github.io %s"
               token dir )
        ; RunShell
            (Printf.sprintf "docker run --rm -v $PWD/%s/%s:/build_result %s" dir
               name repo )
        ; RunShell
            (Printf.sprintf
               "cd %s && git add . && git commit -m \"Update %s\" && git push"
               dir repo ) ]
end

module CommandHandler = struct
  let handle_cmd (_cmd : cmd) : unit = ()
end

(* module EventBus =
   Make_EventBus
     (struct
       type m = msg

       type c = cmd
     end)
     (struct
       let handle_msg = MsgHandler.handle_msg (Sys.getenv "GPB_TOKEN")
     end)
     (CommandHandler) *)
