FROM ocaml/opam:alpine-3.15-ocaml-4.14 AS build

WORKDIR /app

RUN opam install dune

RUN sudo apk add gmp-dev
RUN opam install tls
RUN opam install cohttp-lwt-unix

COPY --chown=opam app .

RUN eval $(opam env) && dune build

RUN ls   -la _build/default/bin

FROM alpine:3.15.5

RUN apk add gmp

WORKDIR /app

COPY --from=build /app/_build/default/bin/main.exe .

EXPOSE 8080

ENTRYPOINT ./main.exe
