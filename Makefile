TEST?=./gitea
GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)

GOFMT ?= gofmt -s

test: fmt-check
	go test -i $(TEST) || exit 1
	echo $(TEST) | \
		xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

testacc: fmt-check
	TF_ACC=1 go test -v $(TEST) $(TESTARGS) -timeout 40m

vet:
	@echo "go vet ."
	@go vet $$(go list ./... | grep -v vendor/) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

.PHONY: fmt-check
fmt-check:
	@diff=$$($(GOFMT) -d $(GOFMT_FILES)); \
	if [ -n "$$diff" ]; then \
		echo "Please run 'make fmt' and commit the result:"; \
		echo "$${diff}"; \
		exit 1; \
	fi;
