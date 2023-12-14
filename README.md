# SUSE utils channel

## Configure

To configure Guix for using this channel you need to create a `.config/guix/channels.scm` file with the following content:

``` scheme
(cons* (channel
        (name 'suse-utils)
        (url "https://github.com/gleidi-suse/suse-utils.git")
        (branch "main")
        ;; Enable signature verification:
        (introduction
         (make-channel-introduction
          "d4a947eb5b4a73f2a467e67569f7aaf3aafc1aa2"
          (openpgp-fingerprint
           "97A2 CB8F B066 F894 9928  CF80 DE9B E0AC E824 6F08"))))
       %default-channels)
```

Otherwise, if you already have a `.config/guix/channels.scm` you can simply prepend this channel to the preexisting ones:

``` scheme
(cons* (channel
        (name 'suse-utils)
        (url "https://github.com/gleidi-suse/suse-utils.git")
        (branch "main")
        ;; Enable signature verification:
        (introduction
         (make-channel-introduction
          "d4a947eb5b4a73f2a467e67569f7aaf3aafc1aa2"
          (openpgp-fingerprint
           "97A2 CB8F B066 F894 9928  CF80 DE9B E0AC E824 6F08"))))
       (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        ;; Enable signature verification:
        (introduction
         (make-channel-introduction
          "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
          (openpgp-fingerprint
           "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
       %default-channels)
```

