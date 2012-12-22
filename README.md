BlogXQ
======
A simple Blog application written in XQuery 1.0

This currently powers the blog on adamretter.org.uk, and has some specific hard-coded parts which suit that website well. However, it could be adapted to work as a generic blog for any website with a little work.

This was originally written in a couple of days in a frenzy of hacking back in 2006 or 2007. Ideally there needs to be better separation of concerns between the logic and the UI. Some seperation exists in a kinda MVVM/MVC way where most of the presentation is in XSLT and the logic in XQuery, but there are some cross-overs. Ideally this should be re-written to use better templating.

The code has some eXist-db (http://www.exist-db.org) specific functions calls, but again these could be asbtracted without too much difficulty to make the code platform independent. 

The code is provided as an eXist-db database backup that may be restored. The entry point is http://www.adamretter.org.uk/blog.xql which probably translates to http://localhost:8080/exist/rest/db/adamretter.org.uk/blog.xql on most development installations of eXist-db.
