#Simple Gspell example

This is just a simple example with gspell and SourceView.

##Requirements

* Vala compiler (preferible 0.30 or newer).
* gtksourceview-3.0 >= 3.18
* gspell git

###To get gspell

git clone git://git.gnome.org/gspell

cd gspell

git checkout 47b9b844e5c5c7f1804a75545c3e6d2481eb18c7

./configure  --prefix=/usr

make

make install

##Compile

cd simple-gspell

make
