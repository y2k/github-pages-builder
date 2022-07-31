open Lib.Domain

let cmd_fmt =
  Fmt.of_to_string (fun xs ->
      `List (List.map (fun (RunShell cmd) -> `String cmd) xs)
      |> Yojson.pretty_to_string )

let cmd_list_from_json json =
  let open Yojson.Basic in
  from_string json |> Util.to_list
  |> List.map (fun j -> RunShell (j |> Util.to_string))

let () =
  let open Alcotest in
  run "E2E"
    [ ( ""
      , [ test_case "test" `Quick (fun _ ->
              let expected =
                {|[
                  "rm -rf __data__",
                  "git clone https://y2khub:_TOKEN_@github.com/y2k/y2k.github.io __data__",
                  "docker run --rm -v $PWD/__data__/tag_game:/build_result y2khub/tag_game",
                  "cd __data__ && git add . && git commit -m \"Update y2khub/tag_game\" && git push"
                ]|}
                |> cmd_list_from_json
              in
              let actual =
                DockerWebHookEvent
                  {|{ "repository": { "repo_name": "y2khub/tag_game", "name": "tag_game" } }|}
                |> MsgHandler.handle_msg "_TOKEN_"
              in
              check (of_pp cmd_fmt) "" expected actual ) ] ) ]
