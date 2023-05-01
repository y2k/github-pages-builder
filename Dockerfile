FROM ocaml/opam:alpine-3.15-ocaml-4.14 AS build

WORKDIR /app

RUN opam install dune

RUN sudo apk add gmp-dev
RUN opam install tls
RUN opam install cohttp-lwt-unix
RUN opam install alcotest yojson

COPY --chown=opam app .

RUN eval $(opam env) && sudo dune build && export OCAMLRUNPARAM=b && sudo make test

FROM docker:20.10.17-alpine3.16

RUN apk add gmp
RUN apk add git

WORKDIR /app

COPY --from=build /app/_build/default/app/main.exe .

EXPOSE 8080
ENV OCAMLRUNPARAM=b

ENTRYPOINT ./main.exe
