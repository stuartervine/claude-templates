.PHONY: combine clean help

# Colors for output
YELLOW := \033[33m
GREEN := \033[32m
RESET := \033[0m

# Find all markdown files except combined.md
MD_FILES := $(filter-out combined.md, $(wildcard *.md))

help:
	@echo "$(YELLOW)Available targets:$(RESET)"
	@echo "  combine  - Create combined.md from selected markdown files"
	@echo "  clean    - Remove combined.md"
	@echo "  help     - Show this help message"

combine:
	@echo "$(YELLOW)Available markdown files:$(RESET)"
	@echo ""
	@selected_files=""; \
	file_list=($(MD_FILES)); \
	for i in $${!file_list[@]}; do \
		echo "  $$((i+1)). $${file_list[i]}"; \
	done; \
	echo ""; \
	echo "$(YELLOW)Enter file numbers to include (space-separated, e.g., '1 3 5'):$(RESET)"; \
	read -r selection; \
	echo ""; \
	if [ -f combined.md ]; then \
		echo "$(YELLOW)combined.md already exists. Overwrite? (y/N):$(RESET)"; \
		read -r confirm; \
		if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			echo "Operation cancelled."; \
			exit 0; \
		fi; \
	fi; \
	echo "# Combined Markdown Files" > combined.md; \
	echo "" >> combined.md; \
	echo "Generated on: $$(date)" >> combined.md; \
	echo "" >> combined.md; \
	for num in $$selection; do \
		if [ "$$num" -ge 1 ] && [ "$$num" -le $${#file_list[@]} ]; then \
			file=$${file_list[$$((num-1))]}; \
			echo "$(GREEN)Adding $$file...$(RESET)"; \
			echo "## $$file" >> combined.md; \
			echo "" >> combined.md; \
			cat "$$file" >> combined.md; \
			echo "" >> combined.md; \
			echo "---" >> combined.md; \
			echo "" >> combined.md; \
		else \
			echo "$(YELLOW)Warning: Invalid selection '$$num' - skipping$(RESET)"; \
		fi; \
	done; \
	echo "$(GREEN)Combined markdown files created as combined.md$(RESET)"

clean:
	@if [ -f combined.md ]; then \
		rm combined.md; \
		echo "$(GREEN)combined.md removed$(RESET)"; \
	else \
		echo "$(YELLOW)combined.md does not exist$(RESET)"; \
	fi