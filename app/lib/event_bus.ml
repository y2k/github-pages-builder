type msg = ..

type cmd = ..

module Make_EventBus (H : sig
  val handle_msg : msg -> cmd list
end) (CH : sig
  val handle_cmd : cmd -> unit
end) =
struct
  let dispatch (msg : msg) : unit =
    H.handle_msg msg |> List.iter CH.handle_cmd
end
