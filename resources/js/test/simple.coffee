

Smack:

~:: p~ Hi! :~

HTML:

<p>Hi!</p>

***

Smack:

~:: p#status.block-message~ Upload Successful! :~

HTML:

<p id="status" class="block-message">Upload Successful!</p>

***

Smack:

~:: Upload Successful! ~p#status.block-message :~

HTML:

<p id="status" class="block-message">Upload Successful!</p>

***

Smack:

~::
  p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~

  Upload Successful!
:~

HTML:

<p id="status" class="block-message" alt="Bla Bla Bla">
  <div class=".clear-fix">
    Upload Successful!
  </div>
</p>

***

Smack:

~:: Upload Successful! ~p#status.block-message |alt:Bla Bla Bla| > div.clear-fix :~

HTML:

<p id="status" class="block-message" alt="Bla Bla Bla">
  <div class=".clear-fix">
    Upload Successful!
  </div>
</p>

***
