PRIVATE_KEY=signingkey.private

all: autosigndir

autosign: autosign.c
	gcc -fPIC -g -c -o autosign.o autosign.c
	ld -shared -o autosign.so autosign.o

gpgkey:
ifeq ($(wildcard $(PRIVATE_KEY)),)
	$(error "Must provide private key `$(PRIVATE_KEY)' to build")
else
	@./import-gpg.sh $(PRIVATE_KEY) ./gpg
endif

autosigndir: gpgkey autosign
	@mkdir -p autosigner
	@cp sign-pkg.sh autosigner
	@cp autosign.so autosigner
	@cp -rf gpg autosigner

zip: autosigndir
	@zip autosigner.zip autosigner/* autosigner/*/*

tgz: autosigndir
	@tar -czvf autosigner.tgz autosigner

clean:
	@rm -f autosign.o autosign.so sign-pkg.sh
	@rm -f autosigner.{zip,tgz}
	@rm -rf autosigner gpg

