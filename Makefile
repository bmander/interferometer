# The shearography head: check the model, export the printed parts, render pictures.
SOLVENTC ?= solventc
PARTS := housing carrier carriage lid
SOURCES := head.sv $(wildcard head/*.sv)
# everything but mirror A's carrier, its mirror and its hardware
MOUNT_HIDE := housing,lid,cube,camera,carriage,filter,pad,mirror_b,fasteners

.PHONY: check stl renders clean
check:
	$(SOLVENTC) head.sv

stl: $(PARTS:%=stl/%.stl)

# one run builds all four, each from the assembly where it stands
$(PARTS:%=stl/%.stl) &: $(SOURCES)
	@mkdir -p stl
	$(SOLVENTC) head.sv --no-check $(foreach p,$(PARTS),--stl stl/$(p).stl --solid $(p).body)

renders: $(SOURCES)
	@mkdir -p renders
	$(SOLVENTC) head.sv --png renders/assembly.png --view isometric --size 1100
	$(SOLVENTC) head.sv --png renders/assembly_open.png --hide lid --view 215,35 --size 1100
	$(SOLVENTC) head.sv --png renders/assembly_top.png --hide lid --view top --size 1100
	$(SOLVENTC) head.sv --png renders/assembly_section.png --hide lid --section y=0mm --view front --size 1100
	$(SOLVENTC) head.sv --png renders/assembly_back.png --view 200,20 --size 1100
	$(SOLVENTC) head.sv --png renders/cube_section_side.png --section x=0mm --view right --size 1100
	$(SOLVENTC) head.sv --png renders/mount_behind.png --hide $(MOUNT_HIDE) --view 215,25 --size 1100
	$(SOLVENTC) head.sv --png renders/mount_front.png --hide $(MOUNT_HIDE) --view 150,20 --size 1100
	$(SOLVENTC) head.sv --png renders/mount_section.png --section x=-19mm --hide lid,fasteners --view right --size 1100

clean:
	rm -rf stl
