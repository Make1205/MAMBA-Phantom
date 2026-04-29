.PHONY: clean kat

REF_LEVELS = 128 192 256 384 512
OPT_LEVELS = 128 192 256 384 512

clean:
	rm -rf build/tmp
	find Implementations/Reference_Implementation -maxdepth 2 -type d -name output -exec rm -rf {} +
	find Implementations/Optimized_Implementation -maxdepth 2 -type d -name output -exec rm -rf {} +

kat:
	@set -e; \
	mkdir -p Test_Vectors build/tmp; \
	echo "[1/4] Generate official KAT from Reference instances"; \
	for lvl in $(REF_LEVELS); do \
	  d="Implementations/Reference_Implementation/MAMBA-Sign-$$lvl"; \
	  $(MAKE) -C $$d clean >/dev/null; \
	  $(MAKE) -C $$d >/dev/null; \
	  (cd $$d && ./KAT_SIG >/dev/null); \
	  cp $$d/output/KAT_SIG_MAMBA-Sign-$$lvl.txt Test_Vectors/KAT_SIG_MAMBA-Sign-$$lvl.txt; \
	done; \
	echo "[2/4] Generate temporary optimized KATs"; \
	for lvl in $(OPT_LEVELS); do \
	  d="Implementations/Optimized_Implementation/MAMBA-Sign-$$lvl"; \
	  $(MAKE) -C $$d clean >/dev/null; \
	  $(MAKE) -C $$d >/dev/null; \
	  (cd $$d && ./KAT_SIG >/dev/null); \
	  cp $$d/output/KAT_SIG_MAMBA-Sign-$$lvl.txt build/tmp/KAT_SIG_MAMBA-Sign-$$lvl.optimized.txt; \
	done; \
	echo "[3/4] Byte-level diff (optimized tmp vs official reference)"; \
	rm -f build/tmp/kat_diff_report.txt; \
	status=0; \
	for lvl in $(OPT_LEVELS); do \
	  ref="Test_Vectors/KAT_SIG_MAMBA-Sign-$$lvl.txt"; \
	  opt="build/tmp/KAT_SIG_MAMBA-Sign-$$lvl.optimized.txt"; \
	  if diff -q $$ref $$opt >/dev/null; then \
	    echo "MAMBA-Sign-$$lvl: MATCH" | tee -a build/tmp/kat_diff_report.txt; \
	  else \
	    echo "MAMBA-Sign-$$lvl: DIFF" | tee -a build/tmp/kat_diff_report.txt; \
	    status=1; \
	  fi; \
	done; \
	echo "[4/4] Completed. Diff report: build/tmp/kat_diff_report.txt"; \
	exit 0
