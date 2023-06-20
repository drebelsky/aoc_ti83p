.PRECIOUS: %.z80
.PHONY: default clean
TARGETS = $(patsubst %.m4,%.8xp,$(wildcard */*.m4))
TARGETS += $(patsubst %.z80,%.8xp,$(wildcard */*.z80))
TARGETS += $(patsubst %.input,%.8xs,$(wildcard */*.input))
default: $(TARGETS)
clean:
	rm *.8xs *.8xp */*.8xs */*.8xp
%.8xs: %.input
	python3 make_8xs.py $^ $@
%.8xp: %.z80
	spasm $^ $@
%.z80: %.m4
	m4 -P $^ > $@
