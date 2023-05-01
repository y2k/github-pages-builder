open Lib.Domain

let () =
  let open Alcotest in
  run "E2E"
    [ ( ""
      , [ test_case "Checkout tag_game" `Slow (fun _ ->
              let temp_dir = Filename.temp_file "" "" ^ "_dir" in
              Printf.printf "Temp dir: %s\n" temp_dir ;
              make_dispatch
                {token= "_TOKEN_"; temp_dir}
                ( "/webhook2"
                , {|{ "repository": { "repo_name": "y2khub/tag_game", "name": "tag_game" } }|}
                ) ;
              check string "" "" temp_dir ) ] ) ]
