#!/bin/sh

> result.txt

perl finder.pl sample-0-origin.html sample-1-evil-gemini.html make-everything-ok-button
perl finder.pl sample-0-origin.html sample-2-container-and-clone.html make-everything-ok-button
perl finder.pl sample-0-origin.html sample-3-the-escape.html make-everything-ok-button
perl finder.pl sample-0-origin.html sample-4-the-mash.html make-everything-ok-button
