.PHONY: run test e2e

run:
	dune build && export GPB_TOKEN=1 && ./_build/default/app/main.exe

test:
	dune build && ./_build/default/test/test.exe

e2e:
	dune build && ./_build/default/test/integration.exe
