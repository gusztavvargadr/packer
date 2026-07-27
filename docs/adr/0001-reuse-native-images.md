# Reuse native images across derived and Vagrant builds

Each image variant is first produced as a native image for a provider. When its
image source is another image variant, the build imports that provider's native
image, while a Vagrant box is packaged from the same native image. This avoids
repeating expensive operating-system installation and provisioning work while
preserving provider-specific results throughout the build chain.
