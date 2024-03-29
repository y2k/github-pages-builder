open Lib.Domain

let cmd_fmt =
  Fmt.of_to_string (fun xs ->
      `List
        (List.map
           (function RunShell cmd -> `String cmd | _ -> failwith "not impl")
           xs )
      |> Yojson.pretty_to_string )

let cmd_list_from_json json =
  let open Yojson.Basic in
  from_string json |> Util.to_list
  |> List.map (fun j -> RunShell (j |> Util.to_string))

let () =
  let open Alcotest in
  let env = {token= "_TOKEN_"; temp_dir= ""} in
  run "E2E"
    [ ( ""
      , [ test_case "webhook2" `Quick (fun _ ->
              let expected =
                {|[
            "git clone https://y2khub:_TOKEN_@github.com/y2k/y2k.github.io __repo__",
            "cd __repo__ && git config user.email \"itwisterlx@gmail.com\" && git config user.name \"y2k\"",
            "rm -rf __repo__/ff_ext",
            "docker pull -q y2khub/ff_ext",
            "docker rm -f ghb__temp_container__",
            "docker create --name ghb__temp_container__ y2khub/ff_ext",
            "docker cp ghb__temp_container__:/build_result/ __repo__/ff_ext",
            "docker rm -f ghb__temp_container__",
            "cd __repo__ && git add . && git commit -m \"Update y2khub/ff_ext\"",
            "cd __repo__ && git push",
            "rm -rf __repo__"
           ]|}
                |> cmd_list_from_json
              in
              let actual =
                DockerWebHookEvent
                  ( "/webhook2"
                  , {|{ "repository": { "repo_name": "y2khub/ff_ext", "name": "ff_ext" } }|}
                  )
                |> MsgHandler.handle_msg env
              in
              check (of_pp cmd_fmt) "" expected actual )
        ; test_case "webhook1" `Quick (fun _ ->
              let expected =
                {|[
                  "rm -rf __repo__",
                  "rm -rf __build__",
                  "git clone https://y2khub:_TOKEN_@github.com/y2k/y2k.github.io __repo__",
                  "cd __repo__ && git config user.email \"itwisterlx@gmail.com\" && git config user.name \"y2k\"",
                  "rm -rf __repo__/tag_game",
                  "docker pull y2khub/tag_game",
                  "docker run --rm -v gpbuilder_shared:/build_result y2khub/tag_game",
                  "cp -r __build__ __repo__/tag_game",
                  "cd __repo__ && git add . && git commit -m \"Update y2khub/tag_game\" && git push"
                ]|}
                |> cmd_list_from_json
              in
              let actual =
                DockerWebHookEvent
                  ( "/webhook"
                  , {|{ "repository": { "repo_name": "y2khub/tag_game", "name": "tag_game" } }|}
                  )
                |> MsgHandler.handle_msg env
              in
              check (of_pp cmd_fmt) "" expected actual )
        ; test_case "wrong user" `Quick (fun _ ->
              let expected = {|[]|} |> cmd_list_from_json in
              let actual =
                DockerWebHookEvent
                  ( "/webhook"
                  , {|{ "repository": { "repo_name": "notme/tag_game", "name": "tag_game" } }|}
                  )
                |> MsgHandler.handle_msg env
              in
              check (of_pp cmd_fmt) "" expected actual ) ] ) ]
