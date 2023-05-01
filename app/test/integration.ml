open Lib.Domain

let _cmd_fmt =
  Fmt.of_to_string (fun xs ->
      `List
        (List.map
           (function RunShell cmd -> `String cmd | _ -> failwith "not impl")
           xs )
      |> Yojson.pretty_to_string )

let () =
  let open Alcotest in
  run "E2E"
    [ ( ""
      , [ test_case "My integration test" `Slow (fun _ ->
              (* Filename.temp_file "111" "222" |> ignore;
                 Printf.printf "Current working directory: | %s |\n" (Sys.getcwd ()) ; *)
              let temp_dir = Filename.temp_file "" "" ^ "_dir" in
              Printf.printf "Temp dir: %s\n" temp_dir ;
              (* Printf.printf "Temp dir: | %s |\n" (Filename.get_temp_dir_name ()) ;
                 Printf.printf "Temp dir: | %s |\n" (Filename.temp_file "" "") ; *)
              make_dispatch {token= "_TOKEN_"}
                ( "/webhook2"
                , {|{ "repository": { "repo_name": "y2khub/tag_game", "name": "tag_game" } }|}
                )
              |> ignore
              (* let actual =
                   DockerWebHookEvent
                     ( "/webhook2"
                     , {|{ "repository": { "repo_name": "y2khub/tag_game", "name": "tag_game" } }|}
                     )
                   |> MsgHandler.handle_msg "_TOKEN_"
                 in
                 let expected = [] in
                 check (of_pp cmd_fmt) "" expected actual ) *) ) ] ) ]
