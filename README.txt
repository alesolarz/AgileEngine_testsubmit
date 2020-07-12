MADE BY ALEJANDRO SOLARZ

finder.pl (Perl v5.30.1)
This program will search for similar elements between 2 HTML files, it uses up to 3 parameters:

1: source file
HTML file to use as comparison with a new one.
2: destination file
HTML file to search for the best Tag candidate similar to source file Tag.
3: pattern
ID of element to use as reference in search (optional). Default: 'make-everything-ok-button'


Example of usage:
perl finder.pl sample-0-origin.html sample-1-evil-gemini.html make-everything-ok-button


Results for sample pages are in result.txt (by running test.sh)