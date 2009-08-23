TARGET=./output/rfc-index.txt ./output/rfc-index.html ./output/rfc-index.zip
DOC=./output/dfd.png ./output/dfd.html

all: $(TARGET)

doc: $(DOC)

output/rfc-index.txt:
	./get_text.pl

output/rfc-index.html: output/rfc-index.txt ./rfc-index.css
	./text2html.pl

output/rfc-index.zip: output/rfc-index.html ./rfc-index.css
	./html2zip.bash

output/dfd.png: dfd.dot
	dot -T png -o $@ $<

output/dfd-map.html: dfd.dot
	dot -T cmapx -o $@ $<

output/dfd.html: output/dfd-map.html
	./map2html.pl

clean:
	rm -f $(TARGET) $(DOC)
