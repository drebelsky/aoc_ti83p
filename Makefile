.PRECIOUS: %.z80
.PHONY: default clean
TARGETS := $(patsubst %.m4,%.8xp,$(wildcard */*p1.m4))
TARGETS += $(patsubst %.m4,%.8xp,$(wildcard */*p2.m4))
TARGETS += $(patsubst %both.m4,%p1.8xp,$(wildcard */*both.m4))
TARGETS += $(patsubst %both.m4,%p2.8xp,$(wildcard */*both.m4))
TARGETS += $(patsubst %.z80,%.8xp,$(wildcard */*p1.z80))
TARGETS += $(patsubst %.z80,%.8xp,$(wildcard */*p2.z80))
TARGETS += $(patsubst %both.z80,%p1.8xp,$(wildcard */*both.z80))
TARGETS += $(patsubst %both.z80,%p2.8xp,$(wildcard */*both.z80))
TARGETS += $(patsubst %.input,%.8xs,$(wildcard */*.input))
default: $(TARGETS)
clean:
	rm *.8xs *.8xp */*.8xs */*.8xp
%.8xs: %.input
	python3 make_8xs.py $^ $@
%.8xp: %.z80
	spasm $^ $@
%p1.8xp: %both.z80
	spasm $^ $@ -DPART1
%p2.8xp: %both.z80
	spasm $^ $@ -DPART2
%.z80: %.m4
	m4 -P $^ > $@
