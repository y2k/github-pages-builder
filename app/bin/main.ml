open Cohttp_lwt_unix
open Lwt.Syntax

let server dispatch =
  let callback _conn _req body =
    let* json = body |> Cohttp_lwt.Body.to_string in
    dispatch json ;
    Server.respond_string ~status:`OK ~body:"" ()
  in
  Server.create ~mode:(`TCP (`Port 8080)) (Server.make ~callback ())

let () =
  let dispatch = Lib.Domain.make_dispatch (Sys.getenv "GPB_TOKEN") in
  print_endline "Server started..." ;
  Lwt_main.run @@ server dispatch
