# RPM Auto Signer

   Simple auto-signing package for RPMs.

   Usually, signing RPM packages requires user interaction when entering the passphrase.
   I've used a method borrowed from a blog post to allow signing automation.
   
   http://blog.oddbit.com/2011/07/fixing-rpmsign-with-evil-magic.html

# Using the auto signer

   1. copy your private key into the repository directory and name it "signingkey.private".
   2. Run: make
   3. Run: cd autosigner
   4. Run: ./sign-pkg.sh <my-rpm-package>
   
   If all went well your package should be signed without you being prompted.

   Right now the "sign-pkg.sh" script requires that you run it from within the "autosign" directory that gets created by "make".
   This should change eventually.

